import { motion } from "framer-motion";
import { Wrench, Clock, RefreshCw, LogIn } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";
import { StatusVideoBackground } from "@/components/layout/StatusVideoBackground";

const MaintenancePage = () => {
  return (
    <div className="min-h-screen flex items-center justify-center p-4 overflow-hidden relative">
      <StatusVideoBackground overlayColor="from-amber-500/10 via-background/90 to-background" />

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="relative z-10 text-center max-w-lg"
      >
        {/* Animated icon */}
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ type: "spring", stiffness: 200, delay: 0.2 }}
          className="mb-8 inline-flex"
        >
          <div className="relative">
            <div className="w-32 h-32 bg-gradient-to-br from-amber-500/20 to-orange-500/20 rounded-full flex items-center justify-center">
              <motion.div
                animate={{ rotate: [0, 15, -15, 0] }}
                transition={{ duration: 2, repeat: Infinity, repeatDelay: 1 }}
              >
                <Wrench className="w-16 h-16 text-amber-500" />
              </motion.div>
            </div>
            <motion.div
              className="absolute -top-2 -right-2 w-8 h-8 bg-primary rounded-full flex items-center justify-center"
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
            >
              <Clock className="w-4 h-4 text-primary-foreground" />
            </motion.div>
          </div>
        </motion.div>

        {/* Message */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="space-y-4 mb-8"
        >
          <h1 className="text-3xl md:text-4xl font-display font-bold text-foreground">
            Under Maintenance
          </h1>
          <p className="text-muted-foreground text-lg">
            We're performing scheduled maintenance to improve your experience. We'll be back shortly!
          </p>
        </motion.div>

        {/* Progress indicator */}
        <motion.div
          initial={{ opacity: 0, scaleX: 0 }}
          animate={{ opacity: 1, scaleX: 1 }}
          transition={{ delay: 0.6, duration: 0.5 }}
          className="mb-8"
        >
          <div className="h-2 bg-muted rounded-full overflow-hidden">
            <motion.div
              className="h-full bg-gradient-to-r from-amber-500 to-orange-500 rounded-full"
              initial={{ width: "0%" }}
              animate={{ width: ["0%", "70%", "40%", "90%", "60%"] }}
              transition={{ duration: 3, repeat: Infinity, repeatType: "reverse" }}
            />
          </div>
          <p className="text-sm text-muted-foreground mt-2">Working on it...</p>
        </motion.div>

        {/* Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          className="flex flex-col sm:flex-row gap-3 justify-center"
        >
          <Button
            onClick={() => window.location.reload()}
            size="lg"
            className="gap-2"
          >
            <RefreshCw className="w-5 h-5" />
            Try Again
          </Button>
          <Button
            asChild
            variant="outline"
            size="lg"
            className="gap-2"
          >
            <Link to="/auth">
              <LogIn className="w-5 h-5" />
              Admin Login
            </Link>
          </Button>
        </motion.div>

        {/* Estimated time */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1 }}
          className="mt-8 text-sm text-muted-foreground"
        >
          Estimated completion: ~30 minutes
        </motion.p>
      </motion.div>
    </div>
  );
};

export default MaintenancePage;
