library base_pagination;

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/pagination_bloc.dart';

typedef ErrorBuilder = Widget Function(BuildContext context);

typedef PlaceholderBuilder = Widget Function(BuildContext context);

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);

class Pagination<T> extends StatefulWidget {
  final ItemBuilder<T> itemBuilder;

  /// Нижний лоадер пагинации
  final Widget loader;

  /// Виджет ошибки
  final ErrorBuilder errorBuilder;

  /// Виджет загрузки
  /// Если customPlaceholder = false, то он перенимает параметры списка
  /// айтемов, иначе он самостоятельный виджет
  final PlaceholderBuilder placeholderBuilder;
  final bool customPlaceholder;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  /// Контроль кэша
  final double cacheExtent;

  /// Количество элементов по второй оси
  final int crossAxisCount;
  final double childAspectRatio;

  /// Расстояние между элементами по второй оси
  final double crossAxisSpacing;

  /// Расстояние между элементами по главной оси
  final double mainAxisSpacing;

  /// Количество плейсхолдеров во время загрузки
  final int countOfPlaceholders;

  /// Высота от низа экрана, при которой начинать подгрузку
  final int paginationOffset;
  final bool addRepaintBoundaries;
  final bool addAutomaticKeepAlives;

  /// Отступ для списка
  final EdgeInsetsGeometry? padding;

  /// Виджет, отображаемый при пустой листе (default: SizedBox())
  final Widget? emptyWidget;
  final ScrollController? scrollController;

  /// Для диалога на случай ошибки, произошедшей при уже непустом листе
  final VoidCallback? errorCallBack;

  const Pagination({
    Key? key,
    required this.itemBuilder,
    required this.loader,
    required this.errorBuilder,
    required this.placeholderBuilder,
    this.customPlaceholder = false,
    this.shrinkWrap = false,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.cacheExtent = 500.0,
    this.crossAxisCount = 1,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    this.countOfPlaceholders = 1,
    this.paginationOffset = 100,
    this.addRepaintBoundaries = false,
    this.addAutomaticKeepAlives = false,
    this.scrollController,
    this.emptyWidget,
    this.padding,
    this.errorCallBack,
  }) : super(key: key);

  @override
  _PaginationState createState() => _PaginationState<T>();
}

class _PaginationState<T> extends State<Pagination<T>> {
  late ScrollController _scrollController;
  late ScrollPhysics _physics;
  late SliverGridDelegateWithFixedCrossAxisCount _gridDelegate;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
    _physics = widget.physics;
    _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: widget.crossAxisCount,
      childAspectRatio: widget.childAspectRatio,
      crossAxisSpacing: widget.crossAxisSpacing,
      mainAxisSpacing: widget.mainAxisSpacing,
    );
  }

  bool get _shouldFetch =>
      _scrollController.offset >= (_scrollController.position.maxScrollExtent - widget.paginationOffset);

  void _scrollListener() {
    if (_shouldFetch) {
      context.read<PaginationBloc<T>>().add(PaginationFetch());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaginationBloc<T>, PaginationState<T>>(
      listenWhen: (_, state) => !state.build,
      listener: (context, state) {
        if (state.status == PaginationStatus.error) {
          widget.errorCallBack?.call();
        }
      },
      buildWhen: (_, state) => state.build,
      builder: (context, state) {
        switch (state.status) {
          case PaginationStatus.loading:
            return widget.customPlaceholder
                ? widget.placeholderBuilder(context)
                : GridView.builder(
                    itemBuilder: (context, _) => widget.placeholderBuilder(context),
                    gridDelegate: _gridDelegate,
                    itemCount: widget.countOfPlaceholders,
                    shrinkWrap: widget.shrinkWrap,
                    padding: widget.padding,
                    physics: _physics,
                  );

          case PaginationStatus.success:
            return CustomScrollView(
              physics: _physics,
              controller: _scrollController.hasClients ? null : _scrollController,
              cacheExtent: widget.cacheExtent,
              shrinkWrap: widget.shrinkWrap,
              slivers: [
                SliverPadding(
                  padding: widget.padding ??
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 30,
                      ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => widget.itemBuilder(context, state.items[index]),
                      childCount: state.items.length,
                      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                      addRepaintBoundaries: widget.addRepaintBoundaries,
                    ),
                    gridDelegate: _gridDelegate,
                  ),
                ),
                if (state.paginationLoading)
                  SliverToBoxAdapter(
                    child: widget.loader,
                  ),
              ],
            );

          case PaginationStatus.error:
            return widget.errorBuilder(context);

          case PaginationStatus.initial:
            return const SizedBox();

          case PaginationStatus.empty:
            return widget.emptyWidget ?? const SizedBox();
        }
      },
    );
  }
}
