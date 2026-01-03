import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Background } from '@/components/layout/Background';
import { Sidebar } from '@/components/layout/Sidebar';
import { MobileNav } from '@/components/layout/MobileNav';
import { GlassPanel } from '@/components/ui/GlassPanel';
import { ThemeSelector } from '@/components/settings/ThemeSelector';
import { VideoSettingsPanel } from '@/components/video/VideoSettingsPanel';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Button } from '@/components/ui/button';
import { Switch } from '@/components/ui/switch';
import { useAuth } from '@/contexts/AuthContext';
import { useUpdateProfilePrivacy } from '@/hooks/useProfileFeatures';
import { getMALAuthUrl, getAniListAuthUrl, disconnectMAL, disconnectAniList } from '@/lib/externalIntegrations';
import { toast } from 'sonner';
import { 
  ArrowLeft, Palette, Film, Monitor, Info, Link2, Eye, EyeOff, Globe, CheckCircle, ExternalLink, Shield
} from 'lucide-react';

export default function SettingsPage() {
  const navigate = useNavigate();
  const { user, profile, refreshProfile } = useAuth();
  const updatePrivacy = useUpdateProfilePrivacy();
  const [isPublic, setIsPublic] = useState(true);

  useEffect(() => {
    if (profile) {
      setIsPublic(profile.is_public ?? true);
    }
  }, [profile]);

  const handlePrivacyChange = async (value: boolean) => {
    setIsPublic(value);
    try {
      await updatePrivacy.mutateAsync(value);
      toast.success(value ? 'Profile is now public' : 'Profile is now private');
    } catch (error) {
      setIsPublic(!value);
      toast.error('Failed to update privacy settings');
    }
  };

  const handleMALConnect = () => {
    window.location.href = getMALAuthUrl();
  };

  const handleAniListConnect = () => {
    window.location.href = getAniListAuthUrl();
  };

  const handleMALDisconnect = async () => {
    if (!user) return;
    try {
      await disconnectMAL(user.id);
      await refreshProfile();
      toast.success('MyAnimeList disconnected');
    } catch {
      toast.error('Failed to disconnect');
    }
  };

  const handleAniListDisconnect = async () => {
    if (!user) return;
    try {
      await disconnectAniList(user.id);
      await refreshProfile();
      toast.success('AniList disconnected');
    } catch {
      toast.error('Failed to disconnect');
    }
  };

  const hasMAL = !!profile?.mal_access_token;
  const hasAniList = !!profile?.anilist_access_token;

  return (
    <div className="min-h-screen bg-background text-foreground overflow-x-hidden">
      <Background />
      <Sidebar />

      <main className="relative z-10 pl-6 md:pl-32 pr-6 py-6 max-w-[1400px] mx-auto pb-24 md:pb-6">
        {/* Header */}
        <div className="flex items-center gap-4 mb-8">
          <button
            onClick={() => navigate(-1)}
            className="flex items-center gap-2 text-muted-foreground hover:text-foreground transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            <span>Back</span>
          </button>
        </div>

        <div className="mb-8">
          <h1 className="font-display text-3xl md:text-4xl font-bold mb-2">Settings</h1>
          <p className="text-muted-foreground">Customize your viewing experience</p>
        </div>

        {/* Settings Tabs */}
        <Tabs defaultValue="appearance" className="space-y-6">
          <TabsList className="bg-muted/50 p-1 flex-wrap h-auto gap-1">
            <TabsTrigger value="appearance" className="gap-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground">
              <Palette className="w-4 h-4" />
              Appearance
            </TabsTrigger>
            <TabsTrigger value="player" className="gap-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground">
              <Film className="w-4 h-4" />
              Video Player
            </TabsTrigger>
            <TabsTrigger value="display" className="gap-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground">
              <Monitor className="w-4 h-4" />
              Display
            </TabsTrigger>
            <TabsTrigger value="privacy" className="gap-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground">
              <Shield className="w-4 h-4" />
              Privacy
            </TabsTrigger>
            <TabsTrigger value="integrations" className="gap-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground">
              <Link2 className="w-4 h-4" />
              Integrations
            </TabsTrigger>
            <TabsTrigger value="about" className="gap-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground">
              <Info className="w-4 h-4" />
              About
            </TabsTrigger>
          </TabsList>

          {/* Appearance Tab */}
          <TabsContent value="appearance">
            <ThemeSelector />
          </TabsContent>

          {/* Video Player Tab */}
          <TabsContent value="player">
            <GlassPanel className="p-6">
              <h2 className="font-display text-xl font-semibold mb-6 flex items-center gap-2">
                <Film className="w-5 h-5 text-primary" />
                Video Player Settings
              </h2>
              <VideoSettingsPanel isOpen={true} onClose={() => {}} embedded />
            </GlassPanel>
          </TabsContent>

          {/* Display Tab */}
          <TabsContent value="display">
            <GlassPanel className="p-6">
              <h2 className="font-display text-xl font-semibold mb-6 flex items-center gap-2">
                <Monitor className="w-5 h-5 text-primary" />
                Display Settings
              </h2>
              <div className="space-y-6">
                <div className="flex items-center justify-between p-4 rounded-xl bg-muted/30">
                  <div>
                    <p className="font-medium">Reduce Motion (Soon)</p>
                    <p className="text-sm text-muted-foreground">Minimize animations for better performance</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" className="sr-only peer" />
                    <div className="w-11 h-6 bg-muted rounded-full peer peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-foreground after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                  </label>
                </div>
                <div className="flex items-center justify-between p-4 rounded-xl bg-muted/30">
                  <div>
                    <p className="font-medium">High Contrast Mode (Soon)</p>
                    <p className="text-sm text-muted-foreground">Increase visual contrast for accessibility</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" className="sr-only peer" />
                    <div className="w-11 h-6 bg-muted rounded-full peer peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-foreground after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                  </label>
                </div>
              </div>
            </GlassPanel>
          </TabsContent>

          {/* Privacy Tab */}
          <TabsContent value="privacy">
            <GlassPanel className="p-6">
              <h2 className="font-display text-xl font-semibold mb-6 flex items-center gap-2">
                <Shield className="w-5 h-5 text-primary" />
                Privacy Settings
              </h2>
              {user ? (
                <div className="space-y-6">
                  <div className="flex items-center justify-between p-4 rounded-xl bg-muted/30">
                    <div className="flex items-center gap-4">
                      {isPublic ? (
                        <Globe className="w-6 h-6 text-green-500" />
                      ) : (
                        <EyeOff className="w-6 h-6 text-muted-foreground" />
                      )}
                      <div>
                        <p className="font-medium">Public Profile</p>
                        <p className="text-sm text-muted-foreground">
                          {isPublic 
                            ? 'Your profile, watchlist, and history are visible to everyone'
                            : 'Only you can see your profile, watchlist, and history'}
                        </p>
                      </div>
                    </div>
                    <Switch 
                      checked={isPublic} 
                      onCheckedChange={handlePrivacyChange}
                      disabled={updatePrivacy.isPending}
                    />
                  </div>
                  <div className="p-4 rounded-xl bg-muted/20 border border-muted">
                    <p className="text-sm text-muted-foreground">
                      When your profile is public, other users can view your:
                    </p>
                    <ul className="mt-2 text-sm text-muted-foreground list-disc list-inside space-y-1">
                      <li>Profile information and avatar</li>
                      <li>Watchlist (favorited anime)</li>
                      <li>Watch history and progress</li>
                      <li>Tier lists you've created</li>
                    </ul>
                  </div>
                </div>
              ) : (
                <div className="text-center py-8">
                  <Shield className="w-12 h-12 mx-auto text-muted-foreground mb-4" />
                  <p className="text-muted-foreground">Sign in to manage your privacy settings</p>
                  <Button onClick={() => navigate('/auth')} className="mt-4">
                    Sign In
                  </Button>
                </div>
              )}
            </GlassPanel>
          </TabsContent>

          {/* Integrations Tab */}
          <TabsContent value="integrations">
            <GlassPanel className="p-6">
              <h2 className="font-display text-xl font-semibold mb-6 flex items-center gap-2">
                <Link2 className="w-5 h-5 text-primary" />
                External Integrations
              </h2>
              {user ? (
                <div className="space-y-6">
                  {/* MyAnimeList */}
                  <div className="flex items-center justify-between p-4 rounded-xl bg-muted/30">
                    <div className="flex items-center gap-4">
                      <div className="w-12 h-12 rounded-lg bg-[#2E51A2] flex items-center justify-center text-white font-bold text-lg">
                        MAL
                      </div>
                      <div>
                        <p className="font-medium">MyAnimeList</p>
                        <p className="text-sm text-muted-foreground">
                          {hasMAL ? (
                            <span className="flex items-center gap-1 text-green-500">
                              <CheckCircle className="w-3 h-3" />
                              Connected
                            </span>
                          ) : (
                            'Sync your anime list and ratings'
                          )}
                        </p>
                      </div>
                    </div>
                    {hasMAL ? (
                      <Button 
                        variant="outline" 
                        size="sm"
                        onClick={handleMALDisconnect}
                      >
                        Disconnect
                      </Button>
                    ) : (
                      <Button 
                        size="sm"
                        onClick={handleMALConnect}
                        className="gap-2"
                      >
                        <ExternalLink className="w-4 h-4" />
                        Connect
                      </Button>
                    )}
                  </div>

                  {/* AniList */}
                  <div className="flex items-center justify-between p-4 rounded-xl bg-muted/30">
                    <div className="flex items-center gap-4">
                      <div className="w-12 h-12 rounded-lg bg-[#02A9FF] flex items-center justify-center">
                        <svg viewBox="0 0 24 24" className="w-8 h-8 fill-white">
                          <path d="M6.361 2.943 0 21.056h4.942l1.077-3.133H11.4l1.052 3.133H22.9c.71 0 1.1-.392 1.1-1.101V17.53c0-.71-.39-1.101-1.1-1.101h-6.483V4.045c0-.71-.392-1.102-1.101-1.102h-2.422c-.71 0-1.101.392-1.101 1.102v1.064l-.758-2.166zm2.324 5.948 1.688 5.018H7.144z"/>
                        </svg>
                      </div>
                      <div>
                        <p className="font-medium">AniList</p>
                        <p className="text-sm text-muted-foreground">
                          {hasAniList ? (
                            <span className="flex items-center gap-1 text-green-500">
                              <CheckCircle className="w-3 h-3" />
                              Connected
                            </span>
                          ) : (
                            'Sync your anime list and activity'
                          )}
                        </p>
                      </div>
                    </div>
                    {hasAniList ? (
                      <Button 
                        variant="outline" 
                        size="sm"
                        onClick={handleAniListDisconnect}
                      >
                        Disconnect
                      </Button>
                    ) : (
                      <Button 
                        size="sm"
                        onClick={handleAniListConnect}
                        className="gap-2"
                      >
                        <ExternalLink className="w-4 h-4" />
                        Connect
                      </Button>
                    )}
                  </div>

                  <div className="p-4 rounded-xl bg-muted/20 border border-muted">
                    <p className="text-sm text-muted-foreground">
                      <strong>What syncs:</strong> Your watchlist, watch progress, and ratings will be 
                      automatically synced with connected services. This happens in real-time as you watch.
                    </p>
                  </div>
                </div>
              ) : (
                <div className="text-center py-8">
                  <Link2 className="w-12 h-12 mx-auto text-muted-foreground mb-4" />
                  <p className="text-muted-foreground">Sign in to connect external services</p>
                  <Button onClick={() => navigate('/auth')} className="mt-4">
                    Sign In
                  </Button>
                </div>
              )}
            </GlassPanel>
          </TabsContent>

          {/* About Tab */}
          <TabsContent value="about">
            <GlassPanel className="p-6">
              <h2 className="font-display text-xl font-semibold mb-6 flex items-center gap-2">
                <Info className="w-5 h-5 text-primary" />
                About
              </h2>
              <div className="space-y-4">
                <div className="p-4 rounded-xl bg-muted/30">
                  <p className="font-medium mb-1">Tatakai</p>
                  <p className="text-sm text-muted-foreground">Version 1.0.0</p>
                </div>
                <div className="p-4 rounded-xl bg-muted/30">
                  <p className="text-sm text-muted-foreground">
                    A modern anime streaming platform with Smart TV support, 
                    beautiful themes, and powerful video player features.
                  </p>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="p-4 rounded-xl bg-primary/10 text-center">
                    <p className="text-2xl font-bold text-primary">12</p>
                    <p className="text-sm text-muted-foreground">Themes</p>
                  </div>
                  <div className="p-4 rounded-xl bg-secondary/10 text-center">
                    <p className="text-2xl font-bold text-secondary">∞</p>
                    <p className="text-sm text-muted-foreground">Anime</p>
                  </div>
                </div>
              </div>
            </GlassPanel>
          </TabsContent>
        </Tabs>
      </main>

      <MobileNav />
    </div>
  );
}
