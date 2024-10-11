# Fetch Take-Home Assessment
## Overview
This project was developed to meet the requirements of the Mobile Software Engineering Internship Take-Home Exercise. The app is designed to fetch data from the provided API (`https://fetch-hiring.s3.amazonaws.com/hiring.json`) and present it in an intuitive, user-friendly way. The key functionality includes grouping items by `listId`, sorting them first by `listId` and then by `name`, and filtering out items with empty or null `name` fields. The result is a clean, readable list of data that adheres to all provided requirements.
## Project Requirements and How They Were Met

In this project, I’ve fully addressed all the requirements of the exercise:

- **Grouping**: Items are grouped by `listId`, ensuring the user can easily distinguish between different sets of data. Furthermore, the items are displayed in groups with UI elements that highlight the separation of the groups. These elements include spacing between groups, titles for each group, and different background colors for each group. 
- **Sorting**: Within each group, items are sorted by `name`, providing a logical and structured display. There is more than one way to sort these by name, and the data we fetched is rather vague and up to interpretation. I chose to sort these alphanumerically, which assumes that there is a relationship between the digits in the numbers. That is, rather than sorting in a way that assumes it should follow a pattern of "1, 2, 100, 200", it follows an order of "1, 100, 2, 200" instead, assuming a relationship between digits as opposed to a standard numerical order. If there was information suggesting that numbers should follow their natural order, we could change the implementation as well. 
- **Filtering**: Any items with `null` or blank names are filtered out, maintaining the integrity of the displayed data.

The data is fetched from the specified API endpoint, and the app dynamically updates the view upon retrieval. If there are any errors during this retrieval process, an error is displayed to the user which allows them to try again. These elements combine to meet the criteria of the exercise while maintaining a smooth and responsive user experience.
## Setup Instructions
1. **Clone the repository**
2. **Open the project in Xcode**
3. **Install Dependencies:** The project uses Swift Package Manager (SPM) for dependency management. Ensure all dependencies are resolved by opening the project in Xcode and letting it automatically fetch any necessary packages.
4. **Build and Run**: Select a simulator or a real device, and hit the **Run** button in Xcode to build and run the app. The app was built for iOS 18+, and I recommend using an iPhone 16 simulator.
## Architecture

This project is structured using the **Model-View-ViewModel (MVVM)** architecture. Furthermore, there is an added **Services** layer to separate the networking logic. By adopting these practices, I’ve ensured that the code remains modular, scalable, and testable. 

- **Services**: The `NetworkService` is a general network service that can be utilized throughout the entire codebase. It makes use of dependency injections that allow for both easy testing and more generalizability. 
- **Model**: The `Item` struct defines the core data model and conforms to `Decodable` for easy JSON decoding.
- **ViewModel**: The `ItemsViewViewModel` handles data fetching and processing. It interacts with the `NetworkService` to fetch data from the API,  filters and sorts it, separates it into groups based on `listId`, and gives each group a color. This ViewModel then feeds all of this information into the View. Furthermore, if it encounters an error along the way, it ensures to pass that error along to the view where it will be displayed. It is made in such a way that allows for scalability and maintainability.
- **View**: The user interface is built using SwiftUI. The `ItemsView` is responsible for rendering the grouped and sorted list, and it includes error handling for any issues encountered during data retrieval. The `ItemsView` is separated from the `ContentView` so as to allow for more views in the scaling of this application.

This architecture allows for a clear separation of concerns, making the app easier to maintain and extend.

## Design Decisions
### UI Design:
The app features a minimalistic design with a beige background, black text, and pastel colors for each group, ensuring a clean and accessible interface. This color scheme was chosen for readability and aesthetic consistency across all `listId` sections.
### Light Mode Enforcement:
Given the custom design choices, I made the decision to force the `ItemsView`  to always run in **light mode**. This ensures that the black text remains legible against the beige background, providing a consistent and visually pleasing experience for users, regardless of their system settings.
### Error Handling:
In scenarios where the app encounters a network issue or fails to fetch data, the user is presented with an alert. This error message explains the issue and provides a "Retry" option, allowing the user to attempt the data fetch again. This approach keeps the app user-friendly, even in failure states.

## Testing
### Unit Testing:
Testing was a key focus of the project. I implemented unit tests to ensure the ViewModel and Network layer behaves as expected.

- **ViewModel Tests**: The `ItemsViewViewModelTests` ensure that items are properly grouped, sorted, and filtered. Furthermore, it tests edge cases such as successfully retrieving data from the API, but finding that it is empty. 
- **Network Tests**: I applied dependency injection for the `NetworkService`, which allowed me to mock network responses. By using `MockURLProtocol`, I was able to simulate various scenarios, ensuring that both success and error paths were fully tested.
## Future Improvements
Though the project meets all the requirements, there are always opportunities for refinement. Here are a few ideas I have for how I could continue to refine the project:

- **Optimized Error Handling**: I could introduce more nuanced error messaging or recovery options based on the different types of errors received. Furthermore, I could add a system that allows the user to report errors to the developers.
- **Performance Improvements**: I could add caching to minimize network requests and enhance speed. This would be helpful if the user was navigating through multiple views. Rather than accessing the URL each time the user came to the `ItemsView`, I could set up caching so it remembers the data that was there. 
- **UI Enhancements**: I could also implement further UI enhancements. For example, rather than forcing the view to light mode, I could implement two different color schemes based on the users preference. 
