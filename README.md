# Базовая пагинация, устроенная под бэк WebAnt

Использование:
1. Небходимо создать класс, наследуемый от PaginationBloc и переопределить
метод получения айтемов и геттер их количества
    `class ExampleBloc extends PaginationBloc<T>`
    Где T - дженерик сущности

2. Переопределить в нем методы

«`{dart}< >{BlocProvider<PaginationBloc<T>>(
                create: (_) => UserBloc()..add(PaginationFetch()),
                child: const PaginationScreen(),
              )}«`
              
3. Создать провайдер в вида:
        `BlocProvider<PaginationBloc<T>>(
                create: (_) => UserBloc()..add(PaginationFetch()),
                child: const PaginationScreen(),
              )`
        ## ! ДЖЕНЕРИКИ ОБЯЗАТЕЛЬНО НЕОБХОДИМО УКАЗЫВАТЬ!

4. Виджет для отображения пагинации должен иметь доступ к контексту,
имеющего в зависимости блок. В дженерике та же сущность
        `Pagination<T>(
            ...
        );>`
