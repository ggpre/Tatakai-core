import { motion } from "framer-motion";
import { Ban, ShieldX, Mail, AlertTriangle, User } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { useAuth } from "@/contexts/AuthContext";
import { StatusVideoBackground } from "@/components/layout/StatusVideoBackground";

const BannedPage = () => {
  const { banReason, signOut, user, profile } = useAuth();
  return (
    <div className="min-h-screen flex items-center justify-center p-4 overflow-hidden relative">
      <StatusVideoBackground overlayColor="from-destructive/20 via-background/90 to-background" />

      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
        className="relative z-10 w-full max-w-md"
      >
        <Card className="border-destructive/50 bg-black/40 backdrop-blur-xl shadow-2xl">
          <CardContent className="pt-8 pb-8 text-center">
            {/* Ban icon with animation */}
            <motion.div
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ type: "spring", stiffness: 200, delay: 0.2 }}
              className="mb-6 inline-flex"
            >
              <div className="relative">
                <div className="w-24 h-24 bg-gradient-to-br from-red-500/20 to-red-600/20 rounded-full flex items-center justify-center">
                  <ShieldX className="w-12 h-12 text-red-500" />
                </div>
                <motion.div
                  className="absolute -top-1 -right-1"
                  animate={{ rotate: [0, 10, -10, 0] }}
                  transition={{ duration: 0.5, repeat: Infinity, repeatDelay: 2 }}
                >
                  <Ban className="w-8 h-8 text-red-500" />
                </motion.div>
              </div>
            </motion.div>

            {/* Header */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
            >
              <h1 className="text-2xl md:text-3xl font-display font-bold text-destructive mb-2">
                Account Suspended
              </h1>
              <p className="text-muted-foreground">
                Your access to this platform has been restricted.
              </p>
            </motion.div>

            {/* User info box */}
            {(user || profile) && (
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 }}
                className="mt-4 p-3 bg-muted/30 border border-border/50 rounded-lg"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-destructive/20 flex items-center justify-center">
                    <User className="w-5 h-5 text-destructive" />
                  </div>
                  <div className="text-left">
                    <p className="font-medium text-foreground">{profile?.display_name || 'User'}</p>
                    <p className="text-xs text-muted-foreground">{user?.email}</p>
                  </div>
                  <div className="ml-auto">
                    <span className="px-2 py-1 rounded-full bg-destructive/20 text-destructive text-xs font-medium">
                      BANNED
                    </span>
                  </div>
                </div>
              </motion.div>
            )}

            {/* Reason box */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.5 }}
              className="mt-6 p-4 bg-destructive/10 border border-destructive/20 rounded-lg"
            >
              <div className="flex items-start gap-3 text-left">
                <AlertTriangle className="w-5 h-5 text-destructive shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm font-medium text-foreground mb-1">Reason for suspension:</p>
                  <p className="text-sm text-muted-foreground">
                    {banReason || 'Violation of our Terms of Service. This action was taken after careful review.'}
                  </p>
                </div>
              </div>
            </motion.div>

            {/* Ban details */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.7 }}
              className="mt-6 grid grid-cols-2 gap-4 text-sm"
            >
              <div className="bg-muted/50 rounded-lg p-3">
                <p className="text-muted-foreground">Status</p>
                <p className="font-semibold text-destructive">Permanent</p>
              </div>
              <div className="bg-muted/50 rounded-lg p-3">
                <p className="text-muted-foreground">Date</p>
                <p className="font-semibold text-foreground">{new Date().toLocaleDateString()}</p>
              </div>
            </motion.div>

            {/* Appeal section */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.9 }}
              className="mt-8 space-y-4"
            >
              <p className="text-sm text-muted-foreground">
                If you believe this is a mistake, you can submit an appeal.
              </p>
              <div className="flex flex-col gap-2">
                <Button
                  variant="outline"
                  size="lg"
                  className="w-full gap-2 border-destructive/30 hover:bg-destructive/10"
                  onClick={() => window.open('mailto:appeals@example.com?subject=Ban Appeal')}
                >
                  <Mail className="w-5 h-5" />
                  Submit Appeal
                </Button>
                <Button
                  variant="ghost"
                  size="lg"
                  className="w-full text-muted-foreground"
                  onClick={() => signOut()}
                >
                  Sign Out
                </Button>
              </div>
            </motion.div>
          </CardContent>
        </Card>
      </motion.div>
    </div>
  );
};

export default BannedPage;
