# GitReposViewer

A SwiftUI app that displays GitHub repositories with filtering, grouping, and language insights.

---

## Features

### Grouping
- **Owner Type:** Repositories are grouped by owner type (User or Organization), helping users differentiate between individual and organizational repositories.  
- **Language:** Repositories can be grouped by programming language. The **dominant language** (by maximum bytes) is displayed as the section header for each group.

### Filtering
- Filter repositories by:
  - All
  - User
  - Organization
  - Favorites

### Pagination
- Infinite scrolling and incremental loading of repositories were considered.  
- Current pagination code is commented out due to loader-related issues during development.

### Error Handling
All API and network errors are handled centrally using the `APIError` enum, covering:
- Network unavailability
- Rate limiting
- Invalid responses
- Server errors

The app displays **loading indicators** and **retry options** based on error conditions.

---

## Technical Details

- **Architecture:** SwiftUI + MVVM  
- **Networking:** `APIClient` with centralized error handling and rate limit support  
- **Persistence:** Favorites and language cache stored locally  
- **State Management:** `@StateObject` and `@Published` properties for reactive UI updates

---

## Usage

1. Clone the repository:  
   ```bash
   git clone https://github.com/yourusername/GitReposViewer.git
