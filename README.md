GitReposViewer - 
This project is a SwiftUI app that displays GitHub repositories with filtering and grouping features.

Grouping Strategy - 
Repositories are grouped by owner type (User or Organization). This allows users to quickly differentiate between individual and organizational repositories.

Pagination Strategy - 
Infinite scrolling and pagination were considered for fetching repositories incrementally. Due to loader-related issues during development, the pagination code is currently commented out.

Error Handling - 
All API and network errors are handled via a centralized APIError enum. This covers scenarios such as:

Network unavailability
Rate limiting
Invalid responses
Server errors

The app displays loading states and retry options based on these error conditions.
