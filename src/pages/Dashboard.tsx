import { motion } from 'framer-motion';
import { Sun, LogOut, Plus, Settings } from 'lucide-react';

interface DashboardProps {
  userEmail: string;
  onLogout: () => void;
}

export default function Dashboard({ userEmail, onLogout }: DashboardProps) {
  const userName = userEmail.split('@')[0].charAt(0).toUpperCase() + userEmail.split('@')[0].slice(1);

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.6, ease: 'easeOut' },
    },
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 text-white">
      {/* Navigation */}
      <motion.nav
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="flex justify-between items-center px-6 lg:px-12 py-6 border-b border-slate-700 bg-slate-900/50 backdrop-blur"
      >
        <motion.div className="flex items-center gap-2">
          <Sun className="w-8 h-8 text-amber-400" />
          <span className="text-xl font-bold bg-gradient-to-r from-amber-400 to-orange-400 bg-clip-text text-transparent">
            Daylight
          </span>
        </motion.div>
        <div className="flex items-center gap-4">
          <span className="text-slate-300">{userEmail}</span>
          <motion.button
            onClick={onLogout}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="p-2 hover:bg-slate-700 rounded-lg transition-colors flex items-center gap-2"
          >
            <LogOut className="w-5 h-5" />
            <span className="text-sm">Logout</span>
          </motion.button>
        </div>
      </motion.nav>

      {/* Main Content */}
      <motion.main
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="max-w-6xl mx-auto px-6 lg:px-12 py-20"
      >
        {/* Welcome Section */}
        <motion.div variants={itemVariants} className="mb-16">
          <motion.h1 className="text-5xl font-bold mb-4">
            Welcome back, <span className="bg-gradient-to-r from-amber-400 to-orange-400 bg-clip-text text-transparent">{userName}</span>!
          </motion.h1>
          <motion.p className="text-xl text-slate-400">
            Your workspace is ready. Start creating and managing your reminders to organize your day.
          </motion.p>
        </motion.div>

        {/* Quick Action Cards */}
        <motion.div variants={itemVariants} className="grid md:grid-cols-3 gap-6 mb-16">
          <motion.button
            whileHover={{ y: -10, boxShadow: '0 20px 40px rgba(251, 146, 60, 0.2)' }}
            whileTap={{ scale: 0.95 }}
            className="p-8 bg-gradient-to-br from-slate-800 to-slate-700 border border-slate-600 hover:border-amber-500/30 rounded-2xl transition-all duration-300 text-left"
          >
            <Plus className="w-8 h-8 text-amber-400 mb-4" />
            <h3 className="text-xl font-semibold mb-2">Create a Reminder</h3>
            <p className="text-slate-400">Add your first task or daily routine</p>
          </motion.button>

          <motion.button
            whileHover={{ y: -10, boxShadow: '0 20px 40px rgba(251, 146, 60, 0.2)' }}
            whileTap={{ scale: 0.95 }}
            className="p-8 bg-gradient-to-br from-slate-800 to-slate-700 border border-slate-600 hover:border-amber-500/30 rounded-2xl transition-all duration-300 text-left"
          >
            <Settings className="w-8 h-8 text-amber-400 mb-4" />
            <h3 className="text-xl font-semibold mb-2">Preferences</h3>
            <p className="text-slate-400">Customize your experience</p>
          </motion.button>

          <motion.button
            whileHover={{ y: -10, boxShadow: '0 20px 40px rgba(251, 146, 60, 0.2)' }}
            whileTap={{ scale: 0.95 }}
            className="p-8 bg-gradient-to-br from-slate-800 to-slate-700 border border-slate-600 hover:border-amber-500/30 rounded-2xl transition-all duration-300 text-left"
          >
            <Sun className="w-8 h-8 text-amber-400 mb-4" />
            <h3 className="text-xl font-semibold mb-2">Get Started</h3>
            <p className="text-slate-400">Learn how to use Daylight</p>
          </motion.button>
        </motion.div>

        {/* Workspace Area */}
        <motion.div
          variants={itemVariants}
          className="bg-gradient-to-br from-slate-800/50 to-slate-700/50 border border-slate-600 rounded-2xl p-12 min-h-96 flex flex-col items-center justify-center text-center"
        >
          <motion.div
            animate={{ y: [0, -10, 0] }}
            transition={{ duration: 4, repeat: Infinity }}
            className="mb-6"
          >
            <div className="w-20 h-20 bg-gradient-to-br from-amber-400 to-orange-500 rounded-full flex items-center justify-center shadow-xl">
              <Sun className="w-12 h-12 text-white" />
            </div>
          </motion.div>
          <h2 className="text-3xl font-bold mb-4">Your Workspace</h2>
          <p className="text-slate-400 max-w-lg mb-8">
            This is your blank canvas. Create reminders, organize your day, and build better habits. Your workspace is fully operational and ready to help you stay organized.
          </p>
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="px-8 py-3 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 rounded-lg font-semibold transition-all duration-300 shadow-lg hover:shadow-xl"
          >
            Create Your First Reminder
          </motion.button>
        </motion.div>

        {/* Info Section */}
        <motion.div variants={itemVariants} className="mt-16 p-8 bg-amber-500/10 border border-amber-500/20 rounded-2xl">
          <h3 className="text-2xl font-semibold mb-4 flex items-center gap-2">
            <span className="text-amber-400">✨</span> Getting Started
          </h3>
          <div className="grid md:grid-cols-2 gap-6 text-slate-300">
            <div>
              <p className="font-semibold text-amber-400 mb-2">Features Available:</p>
              <ul className="space-y-2 text-sm">
                <li>• Smart reminder organization</li>
                <li>• Voice input support</li>
                <li>• Recurring daily tasks</li>
                <li>• Progress tracking</li>
              </ul>
            </div>
            <div>
              <p className="font-semibold text-amber-400 mb-2">Tips:</p>
              <ul className="space-y-2 text-sm">
                <li>• Use voice to add reminders hands-free</li>
                <li>• Set recurring tasks for daily routines</li>
                <li>• Customize your preferences anytime</li>
                <li>• Track your progress throughout the day</li>
              </ul>
            </div>
          </div>
        </motion.div>
      </motion.main>

      {/* Footer */}
      <motion.footer
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1 }}
        className="border-t border-slate-700 mt-20 py-8 bg-slate-900/50"
      >
        <div className="max-w-6xl mx-auto px-6 lg:px-12 text-center text-slate-500">
          <p>&copy; 2026 Daylight. Made for a simpler, brighter everyday.</p>
        </div>
      </motion.footer>
    </div>
  );
}
