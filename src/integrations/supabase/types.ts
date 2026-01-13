export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      comment_likes: {
        Row: {
          comment_id: string
          created_at: string
          id: string
          user_id: string
        }
        Insert: {
          comment_id: string
          created_at?: string
          id?: string
          user_id: string
        }
        Update: {
          comment_id?: string
          created_at?: string
          id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "comment_likes_comment_id_fkey"
            columns: ["comment_id"]
            isOneToOne: false
            referencedRelation: "comments"
            referencedColumns: ["id"]
          },
        ]
      }
      comments: {
        Row: {
          anime_id: string
          content: string
          created_at: string
          episode_id: string | null
          id: string
          is_spoiler: boolean | null
          likes_count: number | null
          parent_id: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          anime_id: string
          content: string
          created_at?: string
          episode_id?: string | null
          id?: string
          is_spoiler?: boolean | null
          likes_count?: number | null
          parent_id?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          anime_id?: string
          content?: string
          created_at?: string
          episode_id?: string | null
          id?: string
          is_spoiler?: boolean | null
          likes_count?: number | null
          parent_id?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "comments_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "comments"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_url: string | null
          banner_url: string | null
          bio: string | null
          created_at: string
          display_name: string | null
          id: string
          is_public: boolean
          is_banned: boolean
          ban_reason: string | null
          mal_access_token: string | null
          mal_refresh_token: string | null
          mal_username: string | null
          anilist_access_token: string | null
          anilist_username: string | null
          showcase_anime: Json | null
          social_links: Json | null
          show_watchlist: boolean
          show_history: boolean
          updated_at: string
          user_id: string
          username: string | null
        }
        Insert: {
          avatar_url?: string | null
          banner_url?: string | null
          bio?: string | null
          created_at?: string
          display_name?: string | null
          id?: string
          is_public?: boolean
          is_banned?: boolean
          ban_reason?: string | null
          mal_access_token?: string | null
          mal_refresh_token?: string | null
          mal_username?: string | null
          anilist_access_token?: string | null
          anilist_username?: string | null
          showcase_anime?: Json | null
          social_links?: Json | null
          show_watchlist?: boolean
          show_history?: boolean
          updated_at?: string
          user_id: string
          username?: string | null
        }
        Update: {
          avatar_url?: string | null
          banner_url?: string | null
          bio?: string | null
          created_at?: string
          display_name?: string | null
          id?: string
          is_public?: boolean
          is_banned?: boolean
          ban_reason?: string | null
          mal_access_token?: string | null
          mal_refresh_token?: string | null
          mal_username?: string | null
          anilist_access_token?: string | null
          anilist_username?: string | null
          showcase_anime?: Json | null
          social_links?: Json | null
          show_watchlist?: boolean
          show_history?: boolean
          updated_at?: string
          user_id?: string
          username?: string | null
        }
        Relationships: []
      }
      ratings: {
        Row: {
          anime_id: string
          created_at: string
          id: string
          rating: number
          review: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          anime_id: string
          created_at?: string
          id?: string
          rating: number
          review?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          anime_id?: string
          created_at?: string
          id?: string
          rating?: number
          review?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
      watch_history: {
        Row: {
          anime_id: string
          anime_name: string
          anime_poster: string | null
          completed: boolean | null
          duration_seconds: number | null
          episode_id: string
          episode_number: number
          id: string
          progress_seconds: number | null
          user_id: string
          watched_at: string
        }
        Insert: {
          anime_id: string
          anime_name: string
          anime_poster?: string | null
          completed?: boolean | null
          duration_seconds?: number | null
          episode_id: string
          episode_number: number
          id?: string
          progress_seconds?: number | null
          user_id: string
          watched_at?: string
        }
        Update: {
          anime_id?: string
          anime_name?: string
          anime_poster?: string | null
          completed?: boolean | null
          duration_seconds?: number | null
          episode_id?: string
          episode_number?: number
          id?: string
          progress_seconds?: number | null
          user_id?: string
          watched_at?: string
        }
        Relationships: []
      }
      watchlist: {
        Row: {
          anime_id: string
          anime_name: string
          anime_poster: string | null
          created_at: string
          id: string
          status: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          anime_id: string
          anime_name: string
          anime_poster?: string | null
          created_at?: string
          id?: string
          status?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          anime_id?: string
          anime_name?: string
          anime_poster?: string | null
          created_at?: string
          id?: string
          status?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      tier_lists: {
        Row: {
          id: string
          user_id: string
          title: string
          description: string | null
          items: Json
          is_public: boolean
          share_code: string
          views_count: number
          likes_count: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          title: string
          description?: string | null
          items?: Json
          is_public?: boolean
          share_code?: string
          views_count?: number
          likes_count?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          title?: string
          description?: string | null
          items?: Json
          is_public?: boolean
          share_code?: string
          views_count?: number
          likes_count?: number
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      tier_list_likes: {
        Row: {
          id: string
          tier_list_id: string
          user_id: string
          created_at: string
        }
        Insert: {
          id?: string
          tier_list_id: string
          user_id: string
          created_at?: string
        }
        Update: {
          id?: string
          tier_list_id?: string
          user_id?: string
          created_at?: string
        }
        Relationships: []
      }
      tier_list_comments: {
        Row: {
          id: string
          tier_list_id: string
          user_id: string
          content: string
          parent_id: string | null
          likes_count: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          tier_list_id: string
          user_id: string
          content: string
          parent_id?: string | null
          likes_count?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          tier_list_id?: string
          user_id?: string
          content?: string
          parent_id?: string | null
          likes_count?: number
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "tier_list_comments_tier_list_id_fkey"
            columns: ["tier_list_id"]
            isOneToOne: false
            referencedRelation: "tier_lists"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tier_list_comments_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "tier_list_comments"
            referencedColumns: ["id"]
          },
        ]
      }
      tier_list_comment_likes: {
        Row: {
          id: string
          comment_id: string
          user_id: string
          created_at: string
        }
        Insert: {
          id?: string
          comment_id: string
          user_id: string
          created_at?: string
        }
        Update: {
          id?: string
          comment_id?: string
          user_id?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "tier_list_comment_likes_comment_id_fkey"
            columns: ["comment_id"]
            isOneToOne: false
            referencedRelation: "tier_list_comments"
            referencedColumns: ["id"]
          },
        ]
      }
      custom_video_sources: {
        Row: {
          id: string
          anime_id: string
          anime_title: string
          episode_number: number
          server_name: string
          video_url: string
          quality: string
          is_active: boolean
          priority: number
          added_by: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          anime_id: string
          anime_title: string
          episode_number: number
          server_name: string
          video_url: string
          quality?: string
          is_active?: boolean
          priority?: number
          added_by: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          anime_id?: string
          anime_title?: string
          episode_number?: number
          server_name?: string
          video_url?: string
          quality?: string
          is_active?: boolean
          priority?: number
          added_by?: string
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      page_visits: {
        Row: {
          id: string
          session_id: string
          user_id: string | null
          page_path: string
          ip_address: string | null
          country: string | null
          city: string | null
          user_agent: string | null
          referrer: string | null
          created_at: string
        }
        Insert: {
          id?: string
          session_id: string
          user_id?: string | null
          page_path: string
          ip_address?: string | null
          country?: string | null
          city?: string | null
          user_agent?: string | null
          referrer?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          session_id?: string
          user_id?: string | null
          page_path?: string
          ip_address?: string | null
          country?: string | null
          city?: string | null
          user_agent?: string | null
          referrer?: string | null
          created_at?: string
        }
        Relationships: []
      }
      watch_sessions: {
        Row: {
          id: string
          user_id: string | null
          session_id: string
          anime_id: string
          episode_id: string
          anime_name: string | null
          anime_poster: string | null
          genres: string[] | null
          watch_duration_seconds: number
          start_time: string
          end_time: string | null
          ip_address: string | null
          country: string | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id?: string | null
          session_id: string
          anime_id: string
          episode_id: string
          anime_name?: string | null
          anime_poster?: string | null
          genres?: string[] | null
          watch_duration_seconds?: number
          start_time?: string
          end_time?: string | null
          ip_address?: string | null
          country?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string | null
          session_id?: string
          anime_id?: string
          episode_id?: string
          anime_name?: string | null
          anime_poster?: string | null
          genres?: string[] | null
          watch_duration_seconds?: number
          start_time?: string
          end_time?: string | null
          ip_address?: string | null
          country?: string | null
          created_at?: string
        }
        Relationships: []
      }
      playlists: {
        Row: {
          id: string
          user_id: string
          name: string
          description: string | null
          cover_image: string | null
          is_public: boolean
          items_count: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          name: string
          description?: string | null
          cover_image?: string | null
          is_public?: boolean
          items_count?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          name?: string
          description?: string | null
          cover_image?: string | null
          is_public?: boolean
          items_count?: number
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      playlist_items: {
        Row: {
          id: string
          playlist_id: string
          anime_id: string
          anime_name: string
          anime_poster: string | null
          position: number
          added_at: string
        }
        Insert: {
          id?: string
          playlist_id: string
          anime_id: string
          anime_name: string
          anime_poster?: string | null
          position?: number
          added_at?: string
        }
        Update: {
          id?: string
          playlist_id?: string
          anime_id?: string
          anime_name?: string
          anime_poster?: string | null
          position?: number
          added_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "playlist_items_playlist_id_fkey"
            columns: ["playlist_id"]
            isOneToOne: false
            referencedRelation: "playlists"
            referencedColumns: ["id"]
          },
        ]
      }
      forum_posts: {
        Row: {
          id: string
          user_id: string
          title: string
          content: string
          content_type: string
          anime_id: string | null
          anime_name: string | null
          anime_poster: string | null
          playlist_id: string | null
          tierlist_id: string | null
          flair: string | null
          is_spoiler: boolean
          is_pinned: boolean
          is_locked: boolean
          image_url: string | null
          is_approved: boolean
          upvotes: number
          downvotes: number
          comments_count: number
          views_count: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          title: string
          content: string
          content_type?: string
          anime_id?: string | null
          anime_name?: string | null
          anime_poster?: string | null
          playlist_id?: string | null
          tierlist_id?: string | null
          flair?: string | null
          is_spoiler?: boolean
          is_pinned?: boolean
          is_locked?: boolean
          image_url?: string | null
          is_approved?: boolean
          upvotes?: number
          downvotes?: number
          comments_count?: number
          views_count?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          title?: string
          content?: string
          content_type?: string
          anime_id?: string | null
          anime_name?: string | null
          anime_poster?: string | null
          playlist_id?: string | null
          tierlist_id?: string | null
          flair?: string | null
          is_spoiler?: boolean
          is_pinned?: boolean
          is_locked?: boolean
          image_url?: string | null
          is_approved?: boolean
          upvotes?: number
          downvotes?: number
          comments_count?: number
          views_count?: number
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      forum_comments: {
        Row: {
          id: string
          post_id: string
          user_id: string
          content: string
          parent_id: string | null
          is_spoiler: boolean
          upvotes: number
          downvotes: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          post_id: string
          user_id: string
          content: string
          parent_id?: string | null
          is_spoiler?: boolean
          upvotes?: number
          downvotes?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          post_id?: string
          user_id?: string
          content?: string
          parent_id?: string | null
          is_spoiler?: boolean
          upvotes?: number
          downvotes?: number
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "forum_comments_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "forum_posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "forum_comments_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "forum_comments"
            referencedColumns: ["id"]
          },
        ]
      }
      forum_votes: {
        Row: {
          id: string
          user_id: string
          post_id: string | null
          comment_id: string | null
          vote_type: number
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          post_id?: string | null
          comment_id?: string | null
          vote_type: number
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          post_id?: string | null
          comment_id?: string | null
          vote_type?: number
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "forum_votes_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "forum_posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "forum_votes_comment_id_fkey"
            columns: ["comment_id"]
            isOneToOne: false
            referencedRelation: "forum_comments"
            referencedColumns: ["id"]
          },
        ]
      }
      admin_logs: {
        Row: {
          id: string
          user_id: string
          action: string
          entity_type: string
          entity_id: string | null
          details: Json | null
          ip_address: string | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          action: string
          entity_type: string
          entity_id?: string | null
          details?: Json | null
          ip_address?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          action?: string
          entity_type?: string
          entity_id?: string | null
          details?: Json | null
          ip_address?: string | null
          created_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
      increment_tier_list_views: {
        Args: {
          tier_list_id: string
        }
        Returns: undefined
      }
      increment_forum_post_views: {
        Args: {
          post_id: string
        }
        Returns: undefined
      }
    }
    Enums: {
      app_role: "admin" | "moderator" | "user"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: ["admin", "moderator", "user"],
    },
  },
} as const
