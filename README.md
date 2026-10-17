# Care247 Customer Search

A Flutter app to search customers, see the matching customers in a list and open the full details of one customer. The data comes from the supplied `db.json` through JSON Server.

## Setup and Run

**Versions**

- Flutter: `3.44.0`
- Dart: `3.12.0`

**Install packages**

```
flutter pub get
```

**Start the mock API**

Keep the supplied `db.json` in a folder and run this inside that folder:

```
npm install -g json-server
json-server --watch db.json --port 3001
```

The customers are then available at `http://localhost:3001/customers`.

**Run the app**

```
flutter run
```

**API address**

The address is not written in the screens or the repository. It is only in `lib/infrastructure/config/app_config.dart`.

- Android emulator: `http://10.0.2.2:3001/customers`
- iOS simulator and web: `http://localhost:3001/customers`
- Physical device: set `networkHostIp` in `app_config.dart` to the IP address of the computer where JSON Server is running, for example `'192.168.1.13'`. The phone and the computer must be on the same Wi-Fi.

`networkHostIp` is empty (`''`) by default. Keep it empty for an emulator or simulator. If it has a value, the app always uses that IP and ignores the emulator and simulator addresses.

No other setup is needed.

**Packages**

| Package | Why I used it |
| --- | --- |
| `flutter_bloc` | Cubit for the state of the search screen, plus BlocBuilder, BlocSelector and BlocListener |
| `equatable` | Compare the state objects by value, so the UI rebuilds only when the data really changed |
| `http` | Calls the REST API |

## Architecture

```
lib/
  cubits/search_cubit/       search_cubit.dart, search_state.dart
  infrastructure/config/     app_config.dart, search_config.dart
  infrastructure/models/     customer, address, phone, email
  repositories/              search_repository.dart
  screens/search_screen/     search_screen.dart, widgets/search_textform_field.dart
  screens/result_screen/     new_result_screen.dart (customer detail)
  main.dart
```

The code is split in three parts:

- **Presentation** (`screens`): builds the widgets and passes what the user does to the cubit. There is no API code in the widgets.
- **State** (`cubits`): `SearchCubit` and `SearchState` decide what the screen should show.
- **Data** (`repositories`, `infrastructure`): `SearchRepository` calls the API and filters the customers. The models turn the json into typed classes. The config files keep the API address and the search fields.

`main.dart` creates the `SearchRepository` with a `RepositoryProvider` and gives it to the `SearchCubit` with a `BlocProvider`.

**State management:** Cubit from `flutter_bloc`. The screen has only a few actions (load, search, refresh, clear) so a Bloc with separate events is more than needed. A Cubit keeps the logic out of the widgets and is easy to test.

**Loading, success, empty and error:** `SearchState.status` can be `initial`, `loading`, `success`, `empty` or `error`.

- loading (and initial): a spinner in the list area. The Search button also shows a small spinner.
- success: the list of customers.
- empty: the "No customer found!!!" message with a Retry button.
- error: an error icon, the error message and a Retry button. The same message is also shown once in a red snackbar.

Empty and error screens can also be pulled down to refresh.

**Error handling:** `SearchRepository` turns the technical errors into short messages (no connection, timeout, wrong status code, data that cannot be read). The cubit keeps only that message in the state. The server response body is never shown to the user.

**Navigation:** `Navigator.push` with `MaterialPageRoute`. Tap a customer to open the detail screen. The back arrow in the app bar goes back to the list.

## Configuration-Driven Design

The search fields are defined in `lib/infrastructure/config/search_config.dart` as a list of `FieldConfig` (`key`, `type`, `label`, `placeholder`, `renderOrder`). The list has First Name, Last Name, Date of Birth and Marital Status.

How the form is built from it:

1. The search screen copies the list and sorts it by `renderOrder`.
2. For each field it makes a `TextEditingController` and a `FocusNode`. They are kept in two maps with the field `key` as the map key.
3. `SearchTextFormField` checks `config.type` and shows a text field or a date field.
4. When the user presses Search, the screen reads every controller into a map `{key: value}` and gives it to the cubit.
5. The repository filters the customers with that map. For every key it compares the text with the same key of the customer json.

**How to add a new search field**

Add one more `FieldConfig` to `searchConfig`, for example:

```dart
FieldConfig(
key: 'maritalStatus',
type: FieldType.text,
label: 'Marital Status',
placeholder: 'Enter marital status.',
renderOrder: 4,
),
```

The `key` must be the same as the field name in the customer json.

- Needs a change: only `search_config.dart`.
- Does not need a change: the search screen, `SearchTextFormField`, the cubit and the repository.

If the new field has a new type (not text or date), one more `case` is needed in `SearchTextFormField`.

## Flutter Decisions

**State management:** Cubit, see above.

**Widget lifecycle**

- Controllers and focus nodes are created once in `initState` and disposed in `dispose`.
- The first load runs in a post frame callback and checks `mounted` before it reads the context.
- The date picker checks `context.mounted` after the `await` before it uses the context again.
- The cubit checks `isClosed` before it emits the result of an API call, so nothing is emitted after the cubit is closed.

**Async API handling:** `async/await` and `Future`. The request has a 30 second timeout. While one search is loading, a second search is ignored, so the same request is not sent twice. Pull-to-refresh and Retry send a new request on purpose and keep the filters of the last search.

**Rebuilds and performance**

- The results use `ListView.builder`, so only the items on screen are built.
- The screen is split with `BlocSelector`, `BlocListener` and `BlocBuilder`. The search icon, the search form, the Search button and the list each listen only to the part of the state they need.
- The list has a `buildWhen`. It rebuilds only when the customers, the status or the error message change.
- The snackbar and the clearing of the form are done in `BlocListener` with `listenWhen`, not in `build()`.
- `SearchState` extends `Equatable`.
- Sorting the config and creating the controllers is done once, not in `build()`.

**Keyboard and forms**

- Text fields have the "next" action. The last field has "done", and "done" starts the search.
- Text fields use the name keyboard and no autocorrect.
- Tap outside a text field, or drag the form or the list, to close the keyboard.
- The form is inside a `SingleChildScrollView`, so a keyboard or many fields do not hide the fields.
- Date of Birth opens `showDatePicker` and cannot be typed by hand.

## Trade-offs

- The filter runs on the phone. The app loads all customers and filters them in the repository. This is simple and works with any JSON Server version. For a big database a filter on the server with query parameters would be better.
- There is no pagination, because the supplied data is small.
- The search form and the results are on one screen. The form opens from the search icon in the app bar. A separate results screen would also be possible.
- Every search calls the API again so the data is fresh. A cache would save requests, but the data could be old.
- When a request fails, the error screen replaces the list, even if an older list was loaded before. Keeping the old list under an error banner would be friendlier.
- Search works only on top-level customer fields. Phones, emails and addresses are lists, so a config key for them would not work.
- Dates are `String` (`yyyy-MM-dd`) like in the json, and the filter compares them as text.
- Search is "contains" and ignores upper and lower case. There is no exact match.
- The colors are written in the widgets. A shared `ThemeData` would be cleaner.

## Testing

Tests are in the `test` folder.

- `customer_filter_test.dart`: the customer filter. No filters, blank values, part of a value and upper or lower case, date of birth, many filters together, a field like marital status, no match.
- `search_text_form_field_test.dart`: the reusable form field widget. Text field: label, typing, keyboard type, done and next action. Date field: label and icon, read only, date picker with OK and with Cancel.
- `customer_model_test.dart`: json parsing, full name, primary phone and email, empty lists, missing field.
- `search_config_test.dart`: the search fields, their types, no repeated key or render order, sorted order.
- `search_cubit_test.dart`: state changes (loading, success, empty, error), search, second search ignored while loading, refresh keeps the filters, clear, toggle. A fake repository is used, so no network is needed.
- `customer_model_test_data.dart`: sample customer data used by the tests.

Run all tests:

```
flutter test
```

## Time Spent

About 16 hours.