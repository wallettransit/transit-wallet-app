import { useNavigate } from 'react-router-dom';
import React from 'react';
import { useAppContext } from '../../context/AppContext';
import { motion } from 'framer-motion';
import { ArrowDownLeft, History, CreditCard, Activity } from 'lucide-react';
import styles from './Dashboard.module.css';

export const WalletScreen: React.FC = () => {
  const { state } = useAppContext();
  const navigate = useNavigate();
  const fmt = (n: number) => n.toLocaleString();

  return (
    <div className={styles.walletContainer}>
      <div className={styles.walletHeader}>My Wallet</div>
      
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, ease: 'easeOut' }}
        className={styles.balanceCard}
      >
        <div style={{ position: 'absolute', top: -40, right: -40, width: 120, height: 120, background: 'rgba(255,255,255,0.1)', borderRadius: '50%' }}></div>
        <div style={{ position: 'absolute', bottom: -20, right: 20, width: 80, height: 80, background: 'rgba(255,255,255,0.05)', borderRadius: '50%' }}></div>
        
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 32, position: 'relative' }}>
          <span className={styles.balanceLabel}>AVAILABLE BALANCE</span>
          <CreditCard size={24} color="rgba(255,255,255,0.8)" />
        </div>
        
        <div className={styles.balanceAmount}>
          ₦{fmt(state.balance)}
        </div>
        
        <div className={styles.balanceSub}>
          TransitWallet Driver
        </div>
      </motion.div>

      <div className={styles.actionGrid}>
        <motion.div 
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          onClick={() => navigate('/withdraw-amt')}
          className={styles.actionCard}
        >
          <div className={styles.actionIcon} style={{ background: 'rgba(34, 197, 94, 0.1)' }}>
            <ArrowDownLeft size={24} color="var(--forest-green)" />
          </div>
          <span className={styles.actionLabel}>Withdraw</span>
        </motion.div>
        
        <motion.div 
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          onClick={() => navigate('/history')}
          className={styles.actionCard}
        >
          <div className={styles.actionIcon} style={{ background: '#f3f4f6' }}>
            <History size={24} color="var(--ink)" />
          </div>
          <span className={styles.actionLabel}>History</span>
        </motion.div>
      </div>

      <div className={styles.statsHeader}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <Activity size={18} color="var(--forest-green)" /> Quick Stats
        </div>
      </div>
      
      <div className={styles.statsGrid}>
        <div className={styles.statCol}>
          <div className={styles.statLabel}>Today's Rides</div>
          <div className={styles.statValue}>{state.rides}</div>
        </div>
        <div className={styles.statCol}>
          <div className={styles.statLabel}>Earnings</div>
          <div className={styles.statValueGreen}>₦{fmt(state.todayTotal)}</div>
        </div>
      </div>
    </div>
  );
};
