import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:smart_shop/config/app_config.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/models/category.dart';
import 'package:smart_shop/models/product.dart';
import 'package:smart_shop/services/api_client.dart';
import 'package:smart_shop/services/catalog_service.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/view/product_detail_screen.dart';
import 'package:smart_shop/view/widgets/product_card.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final StoreController _storeController = Get.find<StoreController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final CatalogService _catalogService;

  final List<Product> _products = <Product>[];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _showSearchField = false;

  int _currentPage = 1;
  String _selectedCategorySlug = 'toutes';
  String? _query;
  double? _minPrice;
  double? _maxPrice;
  _SortKey _sortKey = _SortKey.newest;

  bool get _hasActiveFilters {
    return (_query?.isNotEmpty ?? false) ||
        _selectedCategorySlug != 'toutes' ||
        _minPrice != null ||
        _maxPrice != null ||
        _sortKey != _SortKey.newest;
  }

  @override
  void initState() {
    super.initState();
    _catalogService = CatalogService(ApiClient(baseUrl: AppConfig.baseUrl));
    _scrollController.addListener(_onScroll);

    if (_storeController.categories.isEmpty) {
      _storeController.loadCategories();
    }
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading || _isLoadingMore || !_hasMore) {
      return;
    }

    final position = _scrollController.position;
    if (position.userScrollDirection != ScrollDirection.reverse) {
      return;
    }
    if (position.pixels >= position.maxScrollExtent - 220) {
      _loadProducts(loadMore: true);
    }
  }

  Future<void> _loadProducts({bool loadMore = false}) async {
    if (loadMore && (_isLoadingMore || !_hasMore || _isLoading)) {
      return;
    }

    final pageToLoad = loadMore ? _currentPage + 1 : 1;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final result = await _catalogService.fetchProducts(
        query: _query,
        categorySlug: _selectedCategorySlug,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        ordering: _orderingForApi(_sortKey),
        page: pageToLoad,
      );

      final fetched = result['products'] as List<Product>;
      if (!mounted) return;

      setState(() {
        if (loadMore) {
          _products.addAll(fetched);
        } else {
          _products
            ..clear()
            ..addAll(fetched);
        }
        _sortProductsInPlace();
        _currentPage = pageToLoad;
        _hasMore = result['next'] != null;
      });
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les produits: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  Future<void> _applySearch() async {
    final normalized = _searchController.text.trim();
    _query = normalized.isEmpty ? null : normalized;
    await _loadProducts();
  }

  Future<void> _openFilterSheet() async {
    if (_storeController.categories.isEmpty &&
        !_storeController.isLoadingCategories.value) {
      await _storeController.loadCategories();
    }

    final categories = _storeController.categories.isEmpty
        ? <Category>[
            Category(
              name: 'Toutes',
              slug: 'toutes',
              isActive: true,
              createdAt: DateTime.now(),
              productCount: 0,
            ),
          ]
        : _storeController.categories.toList(growable: false);

    final minController = TextEditingController(
      text: _minPrice?.toStringAsFixed(0) ?? '',
    );
    final maxController = TextEditingController(
      text: _maxPrice?.toStringAsFixed(0) ?? '',
    );

    var selectedCategory =
        categories.any((c) => c.slug == _selectedCategorySlug)
        ? _selectedCategorySlug
        : categories.first.slug;
    var selectedSort = _sortKey;

    if (!mounted) {
      return;
    }

    final result = await showModalBottomSheet<_ShopFilters>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Filtres',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category.slug,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<_SortKey>(
                    initialValue: selectedSort,
                    decoration: InputDecoration(
                      labelText: 'Tri',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: _SortKey.newest,
                        child: Text('Nouveautés'),
                      ),
                      DropdownMenuItem(
                        value: _SortKey.priceAsc,
                        child: Text('Prix croissant'),
                      ),
                      DropdownMenuItem(
                        value: _SortKey.priceDesc,
                        child: Text('Prix décroissant'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        selectedSort = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Prix min',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Prix max',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            minController.clear();
                            maxController.clear();
                            setSheetState(() {
                              selectedCategory = 'toutes';
                              selectedSort = _SortKey.newest;
                            });
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final minText = minController.text.trim();
                            final maxText = maxController.text.trim();

                            final parsedMin = minText.isEmpty
                                ? null
                                : double.tryParse(minText.replaceAll(',', '.'));
                            final parsedMax = maxText.isEmpty
                                ? null
                                : double.tryParse(maxText.replaceAll(',', '.'));

                            if ((minText.isNotEmpty && parsedMin == null) ||
                                (maxText.isNotEmpty && parsedMax == null)) {
                              Get.snackbar(
                                'Valeur invalide',
                                'Entrez des montants valides pour les prix.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (parsedMin != null &&
                                parsedMax != null &&
                                parsedMax < parsedMin) {
                              Get.snackbar(
                                'Valeur invalide',
                                'Le prix max doit être supérieur au prix min.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            Navigator.pop(
                              sheetContext,
                              _ShopFilters(
                                categorySlug: selectedCategory,
                                minPrice: parsedMin,
                                maxPrice: parsedMax,
                                sortKey: selectedSort,
                              ),
                            );
                          },
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    minController.dispose();
    maxController.dispose();

    if (result == null) {
      return;
    }

    setState(() {
      _selectedCategorySlug = result.categorySlug;
      _minPrice = result.minPrice;
      _maxPrice = result.maxPrice;
      _sortKey = result.sortKey;
    });

    await _loadProducts();
  }

  String? _orderingForApi(_SortKey sortKey) {
    if (sortKey == _SortKey.newest) {
      return '-created_at';
    }
    return null;
  }

  void _sortProductsInPlace() {
    if (_sortKey == _SortKey.priceAsc) {
      _products.sort((a, b) {
        final ap = a.minPrice ?? double.infinity;
        final bp = b.minPrice ?? double.infinity;
        return ap.compareTo(bp);
      });
      return;
    }

    if (_sortKey == _SortKey.priceDesc) {
      _products.sort((a, b) {
        final ap = a.minPrice ?? -1;
        final bp = b.minPrice ?? -1;
        return bp.compareTo(ap);
      });
      return;
    }

    _products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  String _sortLabel(_SortKey sortKey) {
    switch (sortKey) {
      case _SortKey.newest:
        return 'Nouveautés';
      case _SortKey.priceAsc:
        return 'Prix croissant';
      case _SortKey.priceDesc:
        return 'Prix décroissant';
    }
  }

  String _categoryLabelFromSlug(String slug) {
    if (slug == 'toutes') {
      return 'Toutes';
    }
    for (final category in _storeController.categories) {
      if (category.slug == slug) {
        return category.name;
      }
    }
    return slug;
  }

  void _removeActiveFilter(_ActiveFilterKey filterKey) {
    setState(() {
      switch (filterKey) {
        case _ActiveFilterKey.query:
          _query = null;
          _searchController.clear();
          break;
        case _ActiveFilterKey.category:
          _selectedCategorySlug = 'toutes';
          break;
        case _ActiveFilterKey.minPrice:
          _minPrice = null;
          break;
        case _ActiveFilterKey.maxPrice:
          _maxPrice = null;
          break;
        case _ActiveFilterKey.sort:
          _sortKey = _SortKey.newest;
          break;
      }
    });
    _loadProducts();
  }

  void _clearAllActiveFilters() {
    setState(() {
      _query = null;
      _searchController.clear();
      _selectedCategorySlug = 'toutes';
      _minPrice = null;
      _maxPrice = null;
      _sortKey = _SortKey.newest;
    });
    _loadProducts();
  }

  Widget _buildActiveFiltersBar(double spacing) {
    final chips = <Widget>[];

    if (_query != null && _query!.isNotEmpty) {
      chips.add(
        InputChip(
          label: Text('Recherche: ${_query!}'),
          onDeleted: () => _removeActiveFilter(_ActiveFilterKey.query),
        ),
      );
    }

    if (_selectedCategorySlug != 'toutes') {
      chips.add(
        InputChip(
          label: Text(
            'Catégorie: ${_categoryLabelFromSlug(_selectedCategorySlug)}',
          ),
          onDeleted: () => _removeActiveFilter(_ActiveFilterKey.category),
        ),
      );
    }

    if (_minPrice != null) {
      chips.add(
        InputChip(
          label: Text('Min: ${_minPrice!.toStringAsFixed(0)} FCFA'),
          onDeleted: () => _removeActiveFilter(_ActiveFilterKey.minPrice),
        ),
      );
    }

    if (_maxPrice != null) {
      chips.add(
        InputChip(
          label: Text('Max: ${_maxPrice!.toStringAsFixed(0)} FCFA'),
          onDeleted: () => _removeActiveFilter(_ActiveFilterKey.maxPrice),
        ),
      );
    }

    if (_sortKey != _SortKey.newest) {
      chips.add(
        InputChip(
          label: Text('Tri: ${_sortLabel(_sortKey)}'),
          onDeleted: () => _removeActiveFilter(_ActiveFilterKey.sort),
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filtres actifs',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllActiveFilters,
                child: const Text('Tout effacer'),
              ),
            ],
          ),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 72,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucun produit trouvé',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text('Changez les filtres ou la recherche.'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final spacing = AppResponsive.sectionSpacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showSearchField = !_showSearchField;
                if (!_showSearchField &&
                    _searchController.text.trim().isEmpty) {
                  _query = null;
                }
              });
              if (!_showSearchField && _query == null) {
                _loadProducts();
              }
            },
            icon: Icon(_showSearchField ? Icons.close : Icons.search),
            tooltip: _showSearchField ? 'Fermer la recherche' : 'Rechercher',
          ),
          IconButton(
            onPressed: _openFilterSheet,
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppResponsive.contentMaxWidth(context),
            ),
            child: Padding(
              padding: padding,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _showSearchField
                        ? Padding(
                            key: const ValueKey('search_input'),
                            padding: EdgeInsets.only(
                              bottom: _hasActiveFilters ? 8 : spacing,
                            ),
                            child: TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _applySearch(),
                              decoration: InputDecoration(
                                hintText: 'Rechercher un produit...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    if (_searchController.text.isEmpty) {
                                      return;
                                    }
                                    _searchController.clear();
                                    _applySearch();
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (_hasActiveFilters) _buildActiveFiltersBar(spacing),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _products.isEmpty
                        ? _buildEmptyState(context)
                        : RefreshIndicator(
                            onRefresh: _refreshProducts,
                            child: GridView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  _products.length + (_isLoadingMore ? 1 : 0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        AppResponsive.gridCrossAxisCount(
                                          context,
                                        ),
                                    mainAxisSpacing: AppResponsive.gridSpacing(
                                      context,
                                    ),
                                    crossAxisSpacing: AppResponsive.gridSpacing(
                                      context,
                                    ),
                                    childAspectRatio:
                                        AppResponsive.isMobile(context)
                                        ? 0.66
                                        : 0.72,
                                  ),
                              itemBuilder: (context, index) {
                                if (index >= _products.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final product = _products[index];
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => ProductDetailScreen(product: product),
                                  ),
                                  child: ProductCard(product: product),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopFilters {
  final String categorySlug;
  final double? minPrice;
  final double? maxPrice;
  final _SortKey sortKey;

  const _ShopFilters({
    required this.categorySlug,
    required this.minPrice,
    required this.maxPrice,
    required this.sortKey,
  });
}

enum _ActiveFilterKey { query, category, minPrice, maxPrice, sort }

enum _SortKey { newest, priceAsc, priceDesc }
