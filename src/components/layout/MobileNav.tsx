import { LayoutGrid, Search, Heart, Settings, User, LogIn, Trophy } from "lucide-react";
import { NavIcon } from "@/components/ui/NavIcon";
import { useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";

export function MobileNav() {
  const location = useLocation();
  const navigate = useNavigate();
  const { user, profile, isBanned } = useAuth();

  const isActive = (path: string) => location.pathname === path;

  return (
    <div className="md:hidden fixed bottom-6 left-6 right-6 h-16 bg-card/90 backdrop-blur-2xl border border-border/30 rounded-2xl flex items-center justify-around px-2 z-50 shadow-2xl">
      <NavIcon 
        icon={LayoutGrid} 
        active={isActive("/")} 
        onClick={() => navigate("/")}
      />
      <NavIcon 
        icon={Search} 
        active={isActive("/search")} 
        onClick={() => navigate("/search")}
      />
      <NavIcon 
        icon={Trophy} 
        active={isActive("/tierlists")} 
        onClick={() => navigate("/tierlists")}
      />
      {user && !isBanned ? (
        <NavIcon 
          icon={User} 
          active={location.pathname.startsWith('/@') || isActive("/profile")} 
          onClick={() => navigate(profile?.username ? `/@${profile.username}` : '/profile')}
        />
      ) : (
        <NavIcon 
          icon={LogIn} 
          active={isActive("/auth")} 
          onClick={() => navigate("/auth")}
        />
      )}
      <NavIcon 
        icon={Settings} 
        active={isActive("/settings")} 
        onClick={() => navigate("/settings")}
      />
    </div>
  );
}
