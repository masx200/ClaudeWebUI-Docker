# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Essential Scripts
```bash
# Development mode (concurrent server + client with hot reload)
npm run dev

# Individual services
npm run server    # Backend only (Express + WebSocket)
npm run client    # Frontend only (Vite dev server)

# Production
npm run build     # Build for production
npm run start     # Build and serve production
npm run preview   # Preview production build
```

### Environment Setup
```bash
# Initialize environment
cp .env.example .env
# Edit .env for port configuration (default: API=3008, Frontend=3009)

# Install dependencies
npm install

# Verify Node.js version (requires v20+)
node --version
```

## Architecture Overview

### Frontend Architecture (React + Vite)
- **Entry Point**: `src/main.jsx` - React 18 app initialization
- **Core Components**:
  - `ChatInterface.jsx` - Main Claude Code interaction with streaming WebSocket
  - `FileTree.jsx` - Interactive file explorer with live editing
  - `Shell.jsx` - Terminal interface using XTerm.js and node-pty
  - `GitPanel.jsx` - Git operations and diff viewing
  - `MainContent.jsx` - Tabbed content area coordinator

### Backend Architecture (Node.js + Express)
- **Entry Point**: `server/index.js` - Express server with dual WebSocket endpoints
- **Key Modules**:
  - `claude-cli.js` - Claude Code CLI integration and process management
  - `projects.js` - Project discovery and session management
  - `database/db.js` - SQLite authentication and user management
  - **WebSocket Endpoints**:
    - `/ws` - Chat interface communication 
    - `/shell` - Terminal interface for direct CLI access

### Session Protection System
The application implements sophisticated session protection to prevent project updates from interrupting active conversations. This involves:
- Active session tracking with both real session IDs and temporary identifiers
- WebSocket-based project refresh coordination
- Chat message integrity preservation during updates

## Development Patterns

### State Management
- **Authentication**: JWT tokens with `AuthContext.jsx` provider
- **Theming**: Dark/light mode via `ThemeContext.jsx`
- **WebSocket**: Real-time communication in `utils/websocket.js`
- **API Client**: Authenticated requests in `utils/api.js`

### File System Integration
- Live file tree exploration with permission metadata
- CodeMirror 6 integration for syntax highlighting (20+ languages)
- Binary file serving for images and media
- File operations with automatic backup creation

### Mobile & PWA Support
- Progressive Web App with `manifest.json` and service worker
- Responsive design with touch-friendly interface
- Bottom navigation for mobile thumb navigation
- Home screen installation capability

## Configuration Files

### Build System
- **`vite.config.js`**: Vite configuration with API proxy setup
- **`tailwind.config.js`**: Tailwind customization with design tokens
- **`postcss.config.js`**: PostCSS processing for Tailwind

### Project Dependencies
- **Frontend**: React 18, CodeMirror 6, XTerm.js, React Router, Tailwind CSS
- **Backend**: Express.js, WebSocket (ws), SQLite (better-sqlite3), node-pty
- **Authentication**: JWT (jsonwebtoken), bcrypt for password hashing

## Security Considerations

### Tool Security
- Claude Code tools are **disabled by default** for security
- Tools must be manually enabled through UI settings
- JWT-based authentication with SQLite user storage
- WebSocket authentication via query parameters

### File System Access
- Project scope limited to discovered Claude projects
- Permission checking for file operations
- Binary file handling with MIME type detection

## Key Integration Points

### Claude Code CLI Integration
- Process spawning and PTY management for terminal access
- Session file parsing (JSONL format) for conversation history
- Project discovery from `~/.claude/projects/` directory
- Real-time project updates via file system watching (chokidar)

### WebSocket Communication
- Streaming responses from Claude Code with real-time updates
- Terminal communication for direct CLI access
- Project refresh coordination without interrupting active sessions
- File tree updates and change notifications

## Testing & Quality

### Development Environment
- Node.js v20+ required (specified in `.nvmrc`)
- Concurrent development with hot reload
- Environment variable configuration via `.env`

### Common Development Issues
- **Project Discovery**: Ensure Claude CLI is initialized in at least one project
- **File Permissions**: Verify project directory access and permissions
- **WebSocket Connection**: Check port configuration and firewall settings
- **Tool Access**: Remember tools are disabled by default for security

## Production Deployment

### Build Process
- Vite builds frontend to `/dist` directory
- Express serves static files and API endpoints
- SQLite database initialization on first run
- WebSocket server setup with authentication

### Environment Configuration
- Port configuration via environment variables
- Database file creation and schema initialization
- Static file serving from built frontend
- CORS configuration for cross-origin requests