# Базовая пагинация

Использование:

1. Небходимо создать класс, наследуемый от PaginationBloc и переопределить
метод получения айтемов и геттер их количества
```dart
class ExampleBloc extends PaginationBloc<T>(
    ...
);
```
**Где T - дженерик сущности**   

2. Переопределить в нем методы
3. Создать провайдер:

### Дженерики обязательны
```dart
BlocProvider<PaginationBloc<T>>(
    create: (_) => ExampleBloc()..add(PaginationFetch()),
    child: const ExampleScreen(),
);
```
4. Виджет для отображения пагинации должен иметь доступ к контексту,
имеющего в зависимости блок. В дженерике та же сущность
```dart
Pagination<T>(
    ...
);
```
5. Для рефреша вызывать метод
```dart
context.read<PaginationBloc<T>>().add(PaginationRefresh());
```
