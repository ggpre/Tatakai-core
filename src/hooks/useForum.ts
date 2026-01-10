import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';

export interface ForumPost {
  id: string;
  user_id: string;
  title: string;
  content: string;
  content_type: 'text' | 'image' | 'link' | 'poll';
  anime_id?: string;
  anime_name?: string;
  anime_poster?: string;
  playlist_id?: string;
  tierlist_id?: string;
  character_id?: string;
  character_name?: string;
  flair?: string;
  is_pinned: boolean;
  is_locked: boolean;
  is_spoiler: boolean;
  is_nsfw: boolean;
  upvotes: number;
  downvotes: number;
  comments_count: number;
  views_count: number;
  created_at: string;
  updated_at: string;
  profiles?: {
    user_id: string;
    display_name: string | null;
    avatar_url: string | null;
    username: string | null;
  };
  user_vote?: 1 | -1 | null;
}

export interface ForumComment {
  id: string;
  post_id: string;
  user_id: string;
  parent_id?: string;
  content: string;
  is_spoiler: boolean;
  upvotes: number;
  downvotes: number;
  created_at: string;
  updated_at: string;
  profiles?: {
    user_id: string;
    display_name: string | null;
    avatar_url: string | null;
    username: string | null;
  };
  user_vote?: 1 | -1 | null;
  replies?: ForumComment[];
}

// Fetch forum posts
export function useForumPosts(options?: {
  animeId?: string;
  playlistId?: string;
  tierlistId?: string;
  sortBy?: 'hot' | 'new' | 'top';
  limit?: number;
}) {
  const { user } = useAuth();
  const sortBy = options?.sortBy || 'hot';
  const limit = options?.limit || 20;

  return useQuery({
    queryKey: ['forum_posts', options?.animeId, options?.playlistId, options?.tierlistId, sortBy, limit],
    queryFn: async () => {
      let query = supabase
        .from('forum_posts')
        .select('*')
        .limit(limit);

      // Filter by content references
      if (options?.animeId) {
        query = query.eq('anime_id', options.animeId);
      }
      if (options?.playlistId) {
        query = query.eq('playlist_id', options.playlistId);
      }
      if (options?.tierlistId) {
        query = query.eq('tierlist_id', options.tierlistId);
      }

      // Sort
      if (sortBy === 'hot') {
        query = query.order('is_pinned', { ascending: false }).order('upvotes', { ascending: false });
      } else if (sortBy === 'new') {
        query = query.order('is_pinned', { ascending: false }).order('created_at', { ascending: false });
      } else if (sortBy === 'top') {
        query = query.order('is_pinned', { ascending: false }).order('upvotes', { ascending: false });
      }

      const { data, error } = await query;
      if (error) throw error;

      if (!data || data.length === 0) return [];

      // Fetch profiles
      const userIds = [...new Set(data.map(p => p.user_id))];
      const { data: profiles } = await supabase
        .from('profiles')
        .select('user_id, display_name, avatar_url, username')
        .in('user_id', userIds);

      const profileMap = new Map(profiles?.map(p => [p.user_id, p]) || []);

      // Fetch user votes if logged in
      const voteMap = new Map<string, 1 | -1>();
      if (user && data.length > 0) {
        const { data: votes } = await supabase
          .from('forum_votes')
          .select('post_id, vote_type')
          .eq('user_id', user.id)
          .in('post_id', data.map(p => p.id));

        votes?.forEach(v => {
          if (v.post_id) voteMap.set(v.post_id, v.vote_type as 1 | -1);
        });
      }

      return data.map(post => ({
        ...post,
        profiles: profileMap.get(post.user_id) || null,
        user_vote: voteMap.get(post.id) || null,
      })) as ForumPost[];
    },
  });
}

// Fetch single forum post
export function useForumPost(postId: string) {
  const { user } = useAuth();

  return useQuery({
    queryKey: ['forum_post', postId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('forum_posts')
        .select('*')
        .eq('id', postId)
        .single();

      if (error) throw error;

      // Increment view count
      await supabase.rpc('increment_forum_post_views', { post_id: postId });

      // Fetch profile
      const { data: profile } = await supabase
        .from('profiles')
        .select('user_id, display_name, avatar_url, username')
        .eq('user_id', data.user_id)
        .single();

      // Fetch user vote if logged in
      let userVote: 1 | -1 | null = null;
      if (user) {
        const { data: vote } = await supabase
          .from('forum_votes')
          .select('vote_type')
          .eq('user_id', user.id)
          .eq('post_id', postId)
          .single();

        userVote = vote?.vote_type as 1 | -1 | null;
      }

      return {
        ...data,
        profiles: profile,
        user_vote: userVote,
      } as ForumPost;
    },
    enabled: !!postId,
  });
}

// Fetch comments for a post
export function useForumComments(postId: string) {
  const { user } = useAuth();

  return useQuery({
    queryKey: ['forum_comments', postId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('forum_comments')
        .select('*')
        .eq('post_id', postId)
        .order('created_at', { ascending: true });

      if (error) throw error;
      if (!data || data.length === 0) return [];

      // Fetch profiles
      const userIds = [...new Set(data.map(c => c.user_id))];
      const { data: profiles } = await supabase
        .from('profiles')
        .select('user_id, display_name, avatar_url, username')
        .in('user_id', userIds);

      const profileMap = new Map(profiles?.map(p => [p.user_id, p]) || []);

      // Fetch user votes if logged in
      const voteMap = new Map<string, 1 | -1>();
      if (user && data.length > 0) {
        const { data: votes } = await supabase
          .from('forum_votes')
          .select('comment_id, vote_type')
          .eq('user_id', user.id)
          .in('comment_id', data.map(c => c.id));

        votes?.forEach(v => {
          if (v.comment_id) voteMap.set(v.comment_id, v.vote_type as 1 | -1);
        });
      }

      // Build comment tree
      const comments = data.map(comment => ({
        ...comment,
        profiles: profileMap.get(comment.user_id) || null,
        user_vote: voteMap.get(comment.id) || null,
        replies: [],
      })) as ForumComment[];

      // Nest replies
      const commentMap = new Map(comments.map(c => [c.id, c]));
      const rootComments: ForumComment[] = [];

      comments.forEach(comment => {
        if (comment.parent_id) {
          const parent = commentMap.get(comment.parent_id);
          if (parent) {
            if (!parent.replies) parent.replies = [];
            parent.replies.push(comment);
          }
        } else {
          rootComments.push(comment);
        }
      });

      return rootComments;
    },
    enabled: !!postId,
  });
}

// Create forum post
export function useCreateForumPost() {
  const queryClient = useQueryClient();
  const { user } = useAuth();

  return useMutation({
    mutationFn: async (post: {
      title: string;
      content: string;
      content_type?: 'text' | 'image' | 'link' | 'poll';
      anime_id?: string;
      anime_name?: string;
      anime_poster?: string;
      playlist_id?: string;
      tierlist_id?: string;
      character_id?: string;
      character_name?: string;
      flair?: string;
      is_spoiler?: boolean;
    }) => {
      if (!user) throw new Error('Must be logged in');

      const { data, error } = await supabase
        .from('forum_posts')
        .insert({
          user_id: user.id,
          ...post,
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['forum_posts'] });
    },
  });
}

// Create forum comment
export function useCreateForumComment() {
  const queryClient = useQueryClient();
  const { user } = useAuth();

  return useMutation({
    mutationFn: async ({
      postId,
      content,
      parentId,
      isSpoiler = false,
    }: {
      postId: string;
      content: string;
      parentId?: string;
      isSpoiler?: boolean;
    }) => {
      if (!user) throw new Error('Must be logged in');

      const { data, error } = await supabase
        .from('forum_comments')
        .insert({
          user_id: user.id,
          post_id: postId,
          parent_id: parentId,
          content,
          is_spoiler: isSpoiler,
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['forum_comments', variables.postId] });
      queryClient.invalidateQueries({ queryKey: ['forum_posts'] });
    },
  });
}

// Vote on post or comment
export function useForumVote() {
  const queryClient = useQueryClient();
  const { user } = useAuth();

  return useMutation({
    mutationFn: async ({
      postId,
      commentId,
      voteType,
      currentVote,
    }: {
      postId?: string;
      commentId?: string;
      voteType: 1 | -1;
      currentVote?: 1 | -1 | null;
    }) => {
      if (!user) throw new Error('Must be logged in');

      // If same vote, remove it
      if (currentVote === voteType) {
        if (postId) {
          const { error } = await supabase
            .from('forum_votes')
            .delete()
            .eq('user_id', user.id)
            .eq('post_id', postId);
          if (error) throw error;
        } else if (commentId) {
          const { error } = await supabase
            .from('forum_votes')
            .delete()
            .eq('user_id', user.id)
            .eq('comment_id', commentId);
          if (error) throw error;
        }
        return null;
      }

      // Upsert vote
      const { data, error } = await supabase
        .from('forum_votes')
        .upsert({
          user_id: user.id,
          post_id: postId || null,
          comment_id: commentId || null,
          vote_type: voteType,
        }, {
          onConflict: postId ? 'user_id,post_id' : 'user_id,comment_id',
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: (_, variables) => {
      if (variables.postId) {
        queryClient.invalidateQueries({ queryKey: ['forum_post', variables.postId] });
        queryClient.invalidateQueries({ queryKey: ['forum_posts'] });
      }
      if (variables.commentId) {
        queryClient.invalidateQueries({ queryKey: ['forum_comments'] });
      }
    },
  });
}

// Delete forum post
export function useDeleteForumPost() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (postId: string) => {
      const { error } = await supabase
        .from('forum_posts')
        .delete()
        .eq('id', postId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['forum_posts'] });
    },
  });
}

// Delete forum comment
export function useDeleteForumComment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ commentId, postId }: { commentId: string; postId: string }) => {
      const { error } = await supabase
        .from('forum_comments')
        .delete()
        .eq('id', commentId);

      if (error) throw error;
      return postId;
    },
    onSuccess: (postId) => {
      queryClient.invalidateQueries({ queryKey: ['forum_comments', postId] });
      queryClient.invalidateQueries({ queryKey: ['forum_posts'] });
    },
  });
}
