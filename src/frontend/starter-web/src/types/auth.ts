export interface BffUser { isAuthenticated: boolean; name?: string | null; claims: Array<{ type: string; value: string }> }
