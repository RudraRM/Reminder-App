# Daylight - Personal Reminder App 🌅

A beautiful, accessible reminder application built to help you manage daily tasks and routines with a focus on simplicity, clarity, and peace of mind.

## Overview

**Daylight** is a modern web-based reminder application designed for managing personal reminders and daily routines. With an intuitive interface and accessibility-first approach, it helps users organize their day into manageable chunks—morning, afternoon, and evening—making it easier to stay on track without feeling overwhelmed.

### Key Features

- ✨ **Smart Reminders** - Organize tasks by time of day (Morning, Afternoon, Evening)
- 🎙️ **Voice Input** - Add reminders by speaking them aloud (no typing required)
- 🔄 **Recurring Tasks** - Set up daily routines that repeat automatically
- ✅ **Progress Tracking** - Visual progress ring showing daily completion rate
- 📅 **Date Navigation** - Navigate between days to view and manage future reminders
- ♿ **Accessibility First** - Large text, reduced motion, keyboard navigation, and high contrast
- 🔊 **Gentle Confirmations** - Optional sound feedback when completing tasks
- 💾 **Local Storage** - All reminders saved locally on your device (privacy-first)
- 📱 **Responsive Design** - Works seamlessly on desktop, tablet, and mobile devices

## Tech Stack

- **Frontend Framework:** React 19.2.6
- **Build Tool:** Vite 7.3.2
- **Styling:** Tailwind CSS 4.1.17
- **Language:** TypeScript 5.9.3
- **Icons:** Lucide React 1.43.0
- **Plugin:** vite-plugin-singlefile (for bundling)

## Project Structure

```
├── src/
│   ├── App.tsx           # Main application component
│   ├── main.tsx          # React DOM entry point
│   ├── utils/
│   │   └── cn.ts         # Utility functions for classnames
│   └── index.css         # Global styles
├── public/               # Static assets
├── package.json          # Project dependencies
├── tsconfig.json         # TypeScript configuration
├── vite.config.ts        # Vite configuration
└── README.md             # This file
```

## Getting Started

### Prerequisites

- Node.js 16+ and npm/yarn installed

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Reminder-App
```

2. Install dependencies:
```bash
npm install
```

### Development

Start the development server:
```bash
npm run dev
```

The application will be available at `http://localhost:5173` (or another port if 5173 is in use).

### Building for Production

Build the application for production:
```bash
npm run build
```

The optimized build will be generated in the `dist/` directory.

### Preview Production Build

Preview the production build locally:
```bash
npm run preview
```

## Features in Detail

### 1. **Today's View**
   - See all reminders for today organized by time period
   - Visual progress ring showing completion percentage
   - Quick add buttons for common reminders

### 2. **Voice Input**
   - Use your browser's Web Speech API to add reminders by voice
   - Example: "Call Sarah at 2 PM" automatically parses into a reminder
   - Fallback to text input if voice is unavailable

### 3. **Reminder Management**
   - Add, edit, and delete reminders
   - Set specific time and date
   - Add optional notes for each reminder
   - Mark reminders as complete/incomplete
   - Set recurring daily reminders

### 4. **Accessibility Settings**
   - **Larger Text Mode:** Increases font sizes for better readability
   - **Reduce Motion:** Disables animations for users sensitive to motion
   - **Gentle Confirmation Sound:** Optional audio feedback (660Hz tone)

### 5. **Smart Organization**
   - Reminders automatically grouped by period (Morning, Afternoon, Evening)
   - Filter reminders: All, To Do, or Done
   - Navigate between dates with arrow buttons
   - Completed reminders are tracked separately

### 6. **Progress Tracking**
   - Visual ring showing daily completion percentage
   - Motivational messages as you complete tasks
   - See your achievements in the "Completed" tab

## Data Storage

All reminders are stored locally in your browser using `localStorage`:
- **Key:** `daylight-reminders` - Stores all reminder data
- **Key:** `daylight-large-text` - Text size preference
- **Key:** `daylight-reduce-motion` - Motion preference
- **Key:** `daylight-sound` - Sound preference

**Note:** Data is private to your device and never sent to any server.

## Reminder Data Structure

```typescript
type Reminder = {
  id: string;              // Unique identifier
  title: string;           // Task description
  time: string;            // Time in HH:MM format
  period: 'Morning' | 'Afternoon' | 'Evening';
  category: string;        // medicine, water, family, walk, read, appointment, etc.
  note: string;            // Additional notes
  done: boolean;           // Completion status
  date: string;            // Date in YYYY-MM-DD format
  repeat: boolean;         // Whether this is a daily routine
  completedDates?: string[]; // Dates when this routine was completed
};
```

## Categories

Reminders are organized into categories with associated icons:
- 💊 **Medicine** - Health medications
- 💧 **Water** - Hydration reminders
- 👤 **Family** - Family contacts and calls
- 🚶 **Walk** - Physical activity
- 📖 **Read** - Reading time
- 📅 **Appointment** - Medical and other appointments
- 🔔 **Other** - Miscellaneous reminders

## Browser Support

- ✅ Chrome/Chromium 80+
- ✅ Firefox 75+
- ✅ Safari 13+
- ✅ Edge 80+

**Note:** Voice input requires HTTPS or localhost and browser permission.

## Keyboard Navigation

- **Tab** - Navigate through interactive elements
- **Enter/Space** - Activate buttons and checkboxes
- **Escape** - Close dialogs and modals
- **Arrow Keys** - Navigate date picker (when focused)

## Accessibility Features

- Full keyboard navigation support
- ARIA labels and roles for screen readers
- High contrast text with sufficient color ratios
- Focus indicators on all interactive elements
- Reduced motion support for animations
- Large text mode for improved readability
- Semantic HTML structure

## Audio Feedback

The app includes a gentle 660Hz sine wave tone (250ms duration) when completing reminders (if enabled). This provides non-intrusive confirmation without startling the user.

## Privacy & Security

- 🔒 All data stored locally in browser storage
- ❌ No server communication or data collection
- 🚫 No analytics, cookies, or tracking
- 🔐 No authentication required

## Future Enhancements

Potential features for future versions:
- Cloud sync with user accounts
- Native mobile apps (iOS/Android)
- Push notifications
- Reminder categories and tags
- Dark mode
- Multiple language support
- Reminder attachments
- Collaboration/sharing features

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is open source and available under the MIT License.

## Support & Contact

For questions, issues, or suggestions, please open an issue in the repository.

---

**Made for a simpler, brighter everyday.** ✨

Daylight is designed with a focus on accessibility and simplicity, inspired by Apple's Human Interface Guidelines and task-focused design principles.
