import { motion } from 'framer-motion';
import { Sun, CheckCircle, Zap, Lock, ArrowRight, Sparkles } from 'lucide-react';

interface LandingProps {
  onLoginClick: () => void;
}

export default function Landing({ onLoginClick }: LandingProps) {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.2,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.8, ease: 'easeOut' },
    },
  };

  const floatingVariants = {
    animate: {
      y: [0, -20, 0],
      transition: {
        duration: 4,
        ease: 'easeInOut',
        repeat: Infinity,
      },
    },
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 text-white overflow-hidden">
      {/* Navigation */}
      <motion.nav
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="flex justify-between items-center px-6 lg:px-12 py-6 border-b border-slate-700 bg-slate-900/50 backdrop-blur"
      >
        <motion.div className="flex items-center gap-2" whileHover={{ scale: 1.05 }}>
          <Sun className="w-8 h-8 text-amber-400" />
          <span className="text-xl font-bold bg-gradient-to-r from-amber-400 to-orange-400 bg-clip-text text-transparent">
            Daylight
          </span>
        </motion.div>
        <motion.button
          onClick={onLoginClick}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          className="px-6 py-2.5 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 rounded-lg font-semibold text-sm transition-all duration-300 shadow-lg hover:shadow-xl"
        >
          Log In
        </motion.button>
      </motion.nav>

      {/* Hero Section */}
      <motion.section
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="max-w-6xl mx-auto px-6 lg:px-12 py-20 grid lg:grid-cols-2 gap-12 items-center"
      >
        <div className="space-y-8">
          <motion.div variants={itemVariants} className="space-y-4">
            <motion.span
              variants={itemVariants}
              className="inline-block px-4 py-2 bg-amber-500/10 border border-amber-500/20 rounded-full text-amber-400 text-sm font-semibold"
            >
              ✨ Your day, at your pace
            </motion.span>
            <motion.h1 variants={itemVariants} className="text-5xl lg:text-6xl font-bold leading-tight">
              A Gentle Reminder for
              <span className="block bg-gradient-to-r from-amber-400 via-orange-400 to-red-400 bg-clip-text text-transparent">
                Every Moment That Matters
              </span>
            </motion.h1>
            <motion.p variants={itemVariants} className="text-lg text-slate-300 leading-relaxed">
              Stay organized without feeling overwhelmed. Daylight helps you manage your day with simplicity, clarity, and a touch of warmth.
            </motion.p>
          </motion.div>

          <motion.div variants={itemVariants} className="flex flex-col sm:flex-row gap-4">
            <motion.button
              onClick={onLoginClick}
              whileHover={{ scale: 1.05, boxShadow: '0 20px 40px rgba(251, 146, 60, 0.3)' }}
              whileTap={{ scale: 0.95 }}
              className="px-8 py-4 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 rounded-xl font-semibold text-lg flex items-center justify-center gap-2 transition-all duration-300 shadow-xl"
            >
              Get Started <ArrowRight className="w-5 h-5" />
            </motion.button>
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="px-8 py-4 border-2 border-slate-600 hover:border-slate-500 rounded-xl font-semibold text-lg transition-all duration-300"
            >
              Learn More
            </motion.button>
          </motion.div>
        </div>

        {/* Floating Illustration */}
        <motion.div
          variants={floatingVariants}
          animate="animate"
          className="relative h-96 lg:h-full flex items-center justify-center"
        >
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 20, repeat: Infinity, ease: 'linear' }}
            className="absolute inset-0 bg-gradient-to-r from-amber-500/20 to-orange-500/20 rounded-full blur-3xl"
          />
          <motion.div className="relative z-10 text-center">
            <motion.div
              animate={{ scale: [1, 1.1, 1] }}
              transition={{ duration: 3, repeat: Infinity }}
              className="w-40 h-40 bg-gradient-to-br from-amber-400 to-orange-500 rounded-full flex items-center justify-center shadow-2xl"
            >
              <Sun className="w-24 h-24 text-white" />
            </motion.div>
          </motion.div>
        </motion.div>
      </motion.section>

      {/* Features Section */}
      <motion.section
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        transition={{ duration: 0.8 }}
        viewport={{ once: true, margin: '-100px' }}
        className="max-w-6xl mx-auto px-6 lg:px-12 py-20"
      >
        <motion.h2 className="text-4xl font-bold text-center mb-4">Why Choose Daylight?</motion.h2>
        <motion.p className="text-center text-slate-400 mb-16 text-lg">
          Designed with simplicity and accessibility in mind
        </motion.p>

        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid md:grid-cols-3 gap-8"
        >
          {[
            { icon: CheckCircle, title: 'Smart Reminders', desc: 'Organize tasks by time of day' },
            { icon: Zap, title: 'Voice Input', desc: 'Add reminders by speaking them aloud' },
            { icon: Lock, title: 'Private & Secure', desc: 'All data stored locally on your device' },
          ].map((feature, i) => (
            <motion.div
              key={i}
              variants={itemVariants}
              whileHover={{ y: -10, boxShadow: '0 20px 40px rgba(251, 146, 60, 0.1)' }}
              className="p-8 bg-gradient-to-br from-slate-800 to-slate-700 rounded-2xl border border-slate-600 hover:border-amber-500/30 transition-all duration-300"
            >
              <feature.icon className="w-12 h-12 text-amber-400 mb-4" />
              <h3 className="text-xl font-semibold mb-2">{feature.title}</h3>
              <p className="text-slate-400">{feature.desc}</p>
            </motion.div>
          ))}
        </motion.div>
      </motion.section>

      {/* CTA Section */}
      <motion.section
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        transition={{ duration: 0.8 }}
        viewport={{ once: true }}
        className="max-w-4xl mx-auto px-6 lg:px-12 py-20 text-center"
      >
        <motion.div className="bg-gradient-to-r from-amber-500/10 to-orange-500/10 border border-amber-500/20 rounded-2xl p-12">
          <motion.h2 className="text-4xl font-bold mb-4 flex items-center justify-center gap-2">
            <Sparkles className="w-8 h-8 text-amber-400" />
            Ready to Simplify Your Day?
          </motion.h2>
          <motion.p className="text-slate-300 mb-8 text-lg">
            Join thousands of users who are taking control of their time with Daylight.
          </motion.p>
          <motion.button
            onClick={onLoginClick}
            whileHover={{ scale: 1.08 }}
            whileTap={{ scale: 0.95 }}
            className="px-10 py-4 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 rounded-xl font-bold text-lg transition-all duration-300 shadow-xl hover:shadow-2xl"
          >
            Start Your Journey Free
          </motion.button>
        </motion.div>
      </motion.section>

      {/* Footer */}
      <motion.footer
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        className="border-t border-slate-700 mt-20 py-12 bg-slate-900/50"
      >
        <div className="max-w-6xl mx-auto px-6 lg:px-12">
          <div className="grid md:grid-cols-3 gap-8 mb-8">
            <div>
              <h4 className="font-semibold mb-4">Daylight</h4>
              <p className="text-slate-400">Making every day a little brighter.</p>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Features</h4>
              <ul className="text-slate-400 space-y-2">
                <li><a href="#" className="hover:text-amber-400 transition">Smart Reminders</a></li>
                <li><a href="#" className="hover:text-amber-400 transition">Voice Input</a></li>
                <li><a href="#" className="hover:text-amber-400 transition">Privacy First</a></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Legal</h4>
              <ul className="text-slate-400 space-y-2">
                <li><a href="#" className="hover:text-amber-400 transition">Privacy Policy</a></li>
                <li><a href="#" className="hover:text-amber-400 transition">Terms of Service</a></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-slate-700 pt-8 text-center text-slate-500">
            <p>&copy; 2026 Daylight. All rights reserved.</p>
          </div>
        </div>
      </motion.footer>
    </div>
  );
}
