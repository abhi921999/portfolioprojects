Select * from vesta_credit_risk_dataset;
--percentage of loans are currently in default
SELECT COUNT(*) * 100.0 / (SELECT COUNT(*) FROM vesta_credit_risk_dataset) AS Percantage_Default
from  vesta_credit_risk_dataset
where  Current_Loan_Status = 'Default';

-- average credit score of customers who are currently in good standing 
Select avg(Credit_score) as average_score
from vesta_credit_risk_dataset
where Current_Loan_Status = 'Current';

--average income of customers who have a Predicted_Risk_Score above 0.5
Select avg(Income) as average_income
from vesta_credit_risk_dataset
where Predicted_Risk_Score >0.5;

--customers in each Employment_Status category currently have a loan
Select count(*) as loan_count,Employment_Status
from vesta_credit_risk_dataset
group by Employment_Status
order by loan_count desc;

-- average interest rate for loans with a Predicted_Arrears_Probability greater than 0.5
Select avg(Interest_Rate) as avg_interest_rate
from vesta_credit_risk_dataset
where Predicted_Arrears_Probability > 0.5;

-- average loan amount for customers who have never had any Previous_Delinquencies?
Select avg(Loan_Amount) as average_loan_amount
from vesta_credit_risk_dataset
where  Previous_Delinquencies =0;

--Identify if certain age are more likely to default, which can inform targeted strategies.
SELECT Top 1 Age, AVG(Predicted_Risk_Score) AS Average_Risk_Score
From vesta_credit_risk_dataset
Group by Age
Order by Average_Risk_Score DESC

--if having a co-signer significantly reduces the probability of arrears.
Select Has_Co_Signer, avg(Predicted_Arrears_Probability) as Average_Arrears_Probability
From vesta_credit_risk_dataset
Group by Has_Co_Signer

-- distribution of Current_Loan_Status vary across different Marital_Status categories
Select Count(*) as distribution_count,Marital_Status, Current_Loan_Status
From vesta_credit_risk_dataset
Group by Marital_Status, Current_Loan_Status
Order by distribution_count desc;

--the total revenue generated from loans that are currently classified as Current.
Select SUM(Loan_Amount * Interest_Rate / 100) AS Total_Revenue_Current
From vesta_credit_risk_dataset
Where Current_Loan_Status = 'Current';

--distribution of Predicted_Risk_Score across different Employment_Status categories
Select Employment_Status, AVG(Predicted_Risk_Score) AS Average_Risk_Score
From vesta_credit_risk_dataset
Group by Employment_Status
Order by Average_Risk_Score Desc;

--average interest rate for loans that are currently in default
Select Round(AVG(Interest_Rate),2) AS Average_Interest_Rate_Default
From vesta_credit_risk_dataset
Where Current_Loan_Status = 'Default';


--correlation between Credit_Score and Predicted_Arrears_Probability
Select Credit_Score, AVG(Predicted_Arrears_Probability) AS Avg_Arrears_Probability
From vesta_credit_risk_dataset
Group by Credit_Score
Order by Credit_Score;

--Key demographic factors (age, income, marital status) that are most indicative of a higher predicted arrears probability,
Select Age, Income, Marital_Status, AVG(Predicted_Arrears_Probability) AS Avg_Arrears_Probability
From vesta_credit_risk_dataset
Group by Age, Income, Marital_Status
Order by Avg_Arrears_Probability DESC;

--How much total loan amount is currently at risk of default
Select SUM(Loan_Amount) AS Total_Loan_Amount_At_Risk
From vesta_credit_risk_dataset
Where Predicted_Risk_Score > 0.7;

-- average Predicted_Arrears_Probability for loans that have a co-signer versus those that do not
Select Has_Co_Signer, Round(AVG(Predicted_Arrears_Probability),2) AS Avg_Arrears_Probability
From vesta_credit_risk_dataset
Group by Has_Co_Signer;

--average number of Previous_Delinquencies for customers who are currently in default
Select AVG(Previous_Delinquencies)AS Avg_Previous_Delinquencies_Default
From vesta_credit_risk_dataset
Where Current_Loan_Status = 'Default';

--age group has the highest rate of loan defaults
Select top 5 Age, COUNT(Case When Current_Loan_Status = 'Default' Then 1 End) * 1.0 / COUNT(*) AS Default_Rate
From vesta_credit_risk_dataset
Group by Age
Order by Default_Rate DESC;

--most common reasons for customers entering late payment status?
Select Employment_Status, Income, Marital_Status, COUNT(*) AS Late_Count
From vesta_credit_risk_dataset
Where Current_Loan_Status = 'Late'
Group by Employment_Status, Income, Marital_Status
Order by  Late_Count DESC;

--Using Subqueries to Find High-Risk Loans That Are Still Approved
Select *
From vesta_credit_risk_dataset
Where Predicted_Risk_Score > (SELECT AVG(Predicted_Risk_Score) FROM vesta_credit_risk_dataset)
  AND Current_Loan_Status = 'Current';

  -- Using CTE to Calculate Total Loan Exposure for High-Risk Loans
  With HighRiskLoans as(
   Select Customer_ID, Loan_Amount, Predicted_Risk_Score
    From vesta_credit_risk_dataset
    Where Predicted_Risk_Score > 0.7
   )
Select Customer_ID, Loan_Amount, Predicted_Risk_Score,SUM(Loan_Amount) OVER () AS Total_High_Risk_Exposure
From HighRiskLoans;

--Calculate the Cumulative Sum of Loan Amounts for High-Risk Loans
Select Customer_ID, Loan_Amount, Predicted_Risk_Score,  SUM(Loan_Amount) OVER (Order by Predicted_Risk_Score DESC) AS Cumulative_Loan_Amount
From vesta_credit_risk_dataset
Where Predicted_Risk_Score > 0.7
Order by Predicted_Risk_Score DESC;

-- Ranking by Risk Score with Partitioning by Employment Status
Select Customer_ID, Employment_Status, Predicted_Risk_Score, RANK() OVER (PARTITION BY Employment_Status Order by Predicted_Risk_Score DESC) AS Risk_Rank
From vesta_credit_risk_dataset;


