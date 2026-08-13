import React from 'react';
import { useAppContext } from '../../context/AppContext';
import { ArrowUpRight, ArrowDownLeft } from 'lucide-react';
import { EmptyState } from '../../components/EmptyState';
import styles from './Dashboard.module.css';

export const HistoryScreen: React.FC = () => {
  const { state } = useAppContext();
  const fmt = (n: number) => n.toLocaleString();

  const history = [
    { id: 1, route: 'Withdrawal · GTBank', amt: -12000, time: 'Today, 2:30 PM', isWithdrawal: true },
    { id: 2, route: 'Anthony', amt: 300, time: 'Today, 1:45 PM', isWithdrawal: false },
    { id: 3, route: 'TBS', amt: 400, time: 'Today, 12:20 PM', isWithdrawal: false },
    { id: 4, route: 'Ojota', amt: 150, time: 'Today, 11:15 AM', isWithdrawal: false },
  ];

  return (
    <div className={styles.historyContainer}>
      <div className={styles.historyHeader}>Recent rides</div>
      
      <div className={styles.historyMetrics}>
        <div className={styles.historyMetricCard}>
          <div className={styles.historyMetricValue}>{state.rides}</div>
          <div className={styles.historyMetricLabel}>Rides</div>
        </div>
        <div className={styles.historyMetricCard}>
          <div className={styles.historyMetricValue}>₦{fmt(state.todayTotal)}</div>
          <div className={styles.historyMetricLabel}>Earnings</div>
        </div>
      </div>
      
      <div className={styles.historyList}>
        {history.length === 0 ? (
          <EmptyState message="No history yet" subMessage="Your recent rides and withdrawals will appear here." />
        ) : (
          history.map(h => (
            <div key={h.id} className={styles.historyItem}>
              <div className={styles.historyItemLeft}>
                <div className={styles.historyItemTitle}>
                  {h.isWithdrawal ? <ArrowDownLeft size={16} color="#ef4444" /> : <ArrowUpRight size={16} color="var(--ok-green)" />}
                  {h.route}
                </div>
                <div className={styles.historyItemTime}>{h.time}</div>
              </div>
              <div className={styles.historyItemRight}>
                <div className={`${styles.historyItemAmount} ${h.isWithdrawal ? styles.historyItemAmountExpense : styles.historyItemAmountIncome}`}>
                  {h.isWithdrawal ? '' : '+'}₦{fmt(Math.abs(h.amt))}
                </div>
                <div className={styles.historyItemStatus}>
                  {h.isWithdrawal ? 'Success' : 'Completed'}
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};
