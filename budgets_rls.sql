ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Passengers can manage their own budgets" ON public.budgets;
CREATE POLICY "Passengers can manage their own budgets" 
ON public.budgets 
FOR ALL 
USING (auth.uid() = passenger_id);
