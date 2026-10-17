export type AdminAnalytics = {
  generatedAt: string;
  totals: {
    users: number;
    loginsLast7Days: number;
    loginsLast30Days: number;
    activeUsers7Days: number;
  };
  loginsByDay: Record<string, number>;
  users: AdminUserRow[];
};

export type AdminUserRow = {
  uid: string;
  email: string;
  displayName: string;
  authProvider: string;
  platform: string;
  appVersion: string;
  loginCount: number;
  lastLoginAt: string | null;
  loginsLast7Days: number;
  loginsLast30Days: number;
};
