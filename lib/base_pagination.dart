library base_pagination;

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/pagination_bloc.dart';

typedef ErrorBuilder = Widget Function(BuildContext);

typedef PlaceholderBuilder = Widget Function(BuildContext, int);

typedef ItemBuilder = Widget Function(BuildContext, int);

class Pagination<T> extends StatefulWidget {
  final ItemBuilder itemBuilder;
  final bool shrinkWrap;
  final Widget loader;
  final ErrorBuilder errorBuilder;
  final PlaceholderBuilder placeholderBuilder;
  final ScrollController? scrollController;
  final ScrollPhysics physics;
  final double cacheExtent;
  final Widget? emptyWidget;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final int countOfPlaceholders;
  final EdgeInsetsGeometry? padding;
  final int paginationOffset;

  const Pagination({
    Key? key,
    required this.itemBuilder,
    required this.loader,
    required this.errorBuilder,
    required this.placeholderBuilder,
    this.shrinkWrap = false,
    this.scrollController,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.cacheExtent = 500.0,
    this.emptyWidget,
    this.crossAxisCount = 1,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    this.countOfPlaceholders = 3,
    this.padding,
    this.paginationOffset = 100,
  }) : super(key: key);

  @override
  _PaginationState createState() => _PaginationState<T>();
}

class _PaginationState<T> extends State<Pagination> {
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
      _scrollController.offset == (_scrollController.position.maxScrollExtent - widget.paginationOffset);

  void _scrollListener() {
    if (_shouldFetch) {
      context.read<PaginationBloc>().add(PaginationFetch());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaginationBloc<T>, PaginationState<T>>(
      listenWhen: (_, state) => !state.build,
      listener: (context, state) {},
      buildWhen: (_, state) => state.build,
      builder: (context, state) {
        switch (state.status) {
          case PaginationStatus.loading:
            return GridView.builder(
              itemBuilder: widget.placeholderBuilder,
              gridDelegate: _gridDelegate,
              itemCount: widget.countOfPlaceholders,
              shrinkWrap: widget.shrinkWrap,
              padding: widget.padding,
              physics: _physics,
            );

          case PaginationStatus.success:
            return CustomScrollView(
              physics: _physics,
              controller: _scrollController,
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
                      widget.itemBuilder,
                      childCount: state.items.length,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
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
