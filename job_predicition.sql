-- Server Name: job_prediction_ml
-- DB name: job_predict_db
-- Table Name:placement_data (Imported file:pacement_clean_feat_data.csv )

CREATE TABLE placement_data(
							age_years INTEGER NOT NULL,
							gender VARCHAR(10) NOT NULL,  
							ssc_percentage DECIMAL(5,2) NOT NULL, 
							hsc_percentage DECIMAL(5,2) NOT NULL, 
							degree_percentage DECIMAL(5,2) NOT NULL, 
							degree_specialization VARCHAR(50) NOT NULL,
							technical_score DECIMAL(5,2) NOT NULL, 
							aptitude_score DECIMAL(5,2) NOT NULL, 
							communication_score DECIMAL(5,2) NOT NULL, 
							skills_match_percentage DECIMAL(5,2) NOT NULL, 
							certifications_count INTEGER NOT NULL,
							internship_experience VARCHAR(15) NOT NULL, 
							years_of_experience INTEGER NOT NULL,
							career_switch_willingness VARCHAR(15) NOT NULL, 
							relevant_experience VARCHAR(15) NOT NULL, 
							previous_ctc_lpa DECIMAL(4,2) NOT NULL, 
							expected_ctc_lpa DECIMAL(4,2) NOT NULL,
							company_tier VARCHAR(10) NOT NULL, 
							job_role_match VARCHAR(15) NOT NULL, 
							competition_level VARCHAR(10) NOT NULL, 
							bond_requirement VARCHAR(15) NOT NULL, 
							notice_period_days INTEGER NOT NULL, 
							layoff_history VARCHAR(5) NOT NULL, 
							employment_gap_months INTEGER NOT NULL,
							relocation_willingness VARCHAR(15) NOT NULL,
							status VARCHAR(15) NOT NULL,  
							interview_Score DECIMAL(5,2) NOT NULL,
							experience_cat VARCHAR(10) NOT NULL,  
							academic_score DECIMAL(5,2) NOT NULL, 
							academic_cat VARCHAR(15) NOT NULL, 
							skill_cat VARCHAR(10) NOT NULL, 
							interview_Score_cat VARCHAR(10) NOT NULL,
							placement_prob DECIMAL(5,2) NOT NULL, 
							placement_cat VARCHAR(10) NOT NULL
						)

-- To View Table:
SELECT * FROM placement_data;
-- DROP Table:
DROP TABLE placement_data;
-- Table ROWS: 50124

-- QUERIES:
--1.Candidate Performance Analysis
-- 1.1 Academic scores vs placement outcome

SELECT COUNT(*) AS cou,ROUND(AVG(academic_score),2) AS aca_score_avg,academic_cat, status FROM placement_data
GROUP BY status,academic_cat
ORDER BY status,cou,aca_score_avg;

SELECT
    status,
    COUNT(*) AS Total_Students,
    ROUND(AVG(academic_score), 2) AS Avg_Academic_Score,
    ROUND(MIN(academic_score), 2) AS Min_Score,
    ROUND(MAX(academic_score), 2) AS Max_Score
FROM placement_data
GROUP BY status;
-- 1.2 Skills match vs interview performance

SELECT skill_cat, interview_score_cat,COUNT(*) AS tot_candidate,
COUNT(*) FILTER(WHERE status='Placed') AS placed_cand, -- cond for count 
COUNT(*) FILTER(WHERE status='Not Placed') AS not_placed_cand, -- cond for count agg
ROUND(COUNT(*) FILTER(WHERE status='Placed')*100/COUNT(*),2) AS placement_rate
FROM placement_data
GROUP BY skill_cat, interview_score_cat
ORDER BY skill_cat, interview_score_cat;

-- 1.3 Certification impact on job acceptance

SELECT certifications_count, COUNT(*) AS tot_candidate,
COUNT(*) FILTER(WHERE status='Placed') AS placed_cand, -- cond for count 
COUNT(*) FILTER(WHERE status='Not Placed') AS not_placed_cand-- cond for count agg
FROM placement_data
GROUP BY certifications_count
ORDER BY certifications_count;

--2 Placement & Acceptance Analysis
-- 2.1 Acceptance rate by company tier

SELECT company_tier,status,COUNT(*) AS tot_candidate
--COUNT(*) FILTER(WHERE company_tier='Tier 1') AS tier1_cand, -- cond for count 
--COUNT(*) FILTER(WHERE company_tier='Tier 2') AS tier2_cand,-- cond for count agg
--COUNT(*) FILTER(WHERE company_tier='Tier_3') AS tier3_cand
FROM placement_data
GROUP BY company_tier,status
ORDER BY company_tier,status DESC;

-- 2.2 Experience vs placement success

SELECT relevant_experience, COUNT(*) AS tot_cand,
ROUND(Count(*) FILTER(WHERE status ='Placed')*100/COUNT(*),2) AS relevant_rate-- to find rate
--ROUND(Count(*) FILTER(WHERE status ='Not Placed')*100/COUNT(*),2) AS non_relevant_rate
FROM placement_data
GROUP BY relevant_experience
ORDER BY relevant_experience DESC;

-- no.of exp:
SELECT years_of_experience, COUNT(*) AS tot_cand,
ROUND(Count(*) FILTER(WHERE status ='Placed')*100/COUNT(*),2) AS placed_rate,-- to find rate
ROUND(Count(*) FILTER(WHERE status ='Not Placed')*100/COUNT(*),2) AS non_placed_rate
FROM placement_data
GROUP BY years_of_experience
ORDER BY years_of_experience DESC;

-- 3 Interview & Evaluation Analysis
-- 3.1 Interview score vs placement probability

SELECT interview_score_cat,COUNT(interview_score_cat) AS tot_cand, ROUND(AVG(placement_prob),2) AS avg_placed_prob
FROM placement_data
GROUP BY interview_score_cat
ORDER BY interview_score_cat DESC;

-- 3.2 Employability test score analysis

SELECT
    *,
    technical_score + aptitude_score AS total_score,
    AVG(technical_score + aptitude_score) OVER () AS avg_total_score
FROM placement_data;
--------------------- OR--------------------------------------------
SELECT
    *,
    interview_score + skills_match_percentage AS emp_score,
    AVG(interview_score + skills_match_percentage)
        OVER (PARTITION BY status) AS emp_ana
FROM placement_data
ORDER BY status, emp_score DESC;
	   
