export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          hunter_name: string | null
          xp: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          hunter_name?: string | null
          xp?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          hunter_name?: string | null
          xp?: number
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      quests: {
        Row: {
          id: string
          slug: string
          title: string
          body: Json
          starts_at: string | null
          ends_at: string | null
          is_published: boolean
          archived: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          slug: string
          title: string
          body?: Json
          starts_at?: string | null
          ends_at?: string | null
          is_published?: boolean
          archived?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          slug?: string
          title?: string
          body?: Json
          starts_at?: string | null
          ends_at?: string | null
          is_published?: boolean
          archived?: boolean
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      user_quest_progress: {
        Row: {
          user_id: string
          quest_id: string
          branch: 'CONTROL' | 'OBSERVE' | 'INFLUENCE' | null
          step: number
          state: Json
          completed_at: string | null
          started_at: string | null
          updated_at: string
        }
        Insert: {
          user_id: string
          quest_id: string
          branch?: 'CONTROL' | 'OBSERVE' | 'INFLUENCE' | null
          step?: number
          state?: Json
          completed_at?: string | null
          started_at?: string | null
          updated_at?: string
        }
        Update: {
          user_id?: string
          quest_id?: string
          branch?: 'CONTROL' | 'OBSERVE' | 'INFLUENCE' | null
          step?: number
          state?: Json
          completed_at?: string | null
          started_at?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      answer_attempts: {
        Row: {
          id: string
          user_id: string
          quest_id: string | null
          puzzle_key: string | null
          is_correct: boolean
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          quest_id?: string | null
          puzzle_key?: string | null
          is_correct: boolean
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          quest_id?: string | null
          puzzle_key?: string | null
          is_correct?: boolean
          created_at?: string
        }
        Relationships: []
      }
    }
    Views: Record<string, never>
    Functions: {
      list_active_quest_summaries: {
        Args: Record<string, never>
        Returns: {
          id: string
          slug: string
          title: string
          starts_at: string | null
          ends_at: string | null
        }[]
      }
      get_player_quest_payload: {
        Args: { p_quest_id: string }
        Returns: Json
      }
      ensure_quest_progress: {
        Args: { p_quest_id: string }
        Returns: undefined
      }
      submit_puzzle_answer: {
        Args: {
          p_quest_id: string
          p_puzzle_id: string
          p_attempt: string
        }
        Returns: Json
      }
      submit_finale_choice: {
        Args: { p_quest_id: string; p_choice: string }
        Returns: Json
      }
      run_quest_archive_sweep_admin: {
        Args: Record<string, never>
        Returns: Json
      }
    }
    Enums: Record<string, never>
    CompositeTypes: Record<string, never>
  }
}
