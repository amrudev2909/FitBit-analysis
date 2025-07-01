-- =======================================
-- 1. Categorize Users Based on Usage Frequency
-- =======================================

WITH user_type AS (
    SELECT 
        ID,
        COUNT(ID) AS frequency,
        CASE 
            WHEN COUNT(ID) BETWEEN 21 AND 31 THEN 'Frequent_user'
            WHEN COUNT(ID) BETWEEN 11 AND 20 THEN 'Moderate_user'
            ELSE 'Less_freq_user'
        END AS user_category
    FROM daily_activity
    GROUP BY ID
),

-- =======================================
-- 2. Calculate Lifestyle Category Based on Average Steps
-- =======================================

lifestyle_data AS (
    SELECT 
        da.ID,
        AVG(da.TotalSteps) AS avg_steps,
        AVG(da.Calories) AS avg_calories,
        CASE
            WHEN AVG(da.TotalSteps) BETWEEN 5000 AND 7499 THEN 'Low_Active'
            WHEN AVG(da.TotalSteps) BETWEEN 7500 AND 9999 THEN 'Moderately_Active'
            WHEN AVG(da.TotalSteps) >= 10000 THEN 'Active'
            ELSE 'Sedentary'
        END AS lifestyle
    FROM daily_activity da
    GROUP BY da.ID
),

-- =======================================
-- 3. Prepare Sleep + Activity Merged Data
-- =======================================

sleep_record AS (
    SELECT 
        s.ID,
        s.TotalMinutesAsleep AS sleeptime,
        s.TotalTimeInBed AS bedtime,
        s.[date],
        d.TotalSteps AS steps
    FROM sleep s
    JOIN daily_activity d 
        ON s.ID = d.ID AND s.[date] = d.[date]
)

-- ==============================
-- FINAL QUERIES
-- ==============================

-- A. Average Activity by Day of the Week
SELECT 
    DATENAME(weekday, [date]) AS day_name,
    AVG(TotalSteps) AS average_steps,
    AVG(VeryActiveMinutes) AS active_minutes,
    AVG(FairlyActiveMinutes) AS fair_minutes,
    AVG(LightlyActiveMinutes) AS light_minutes,
    AVG(SedentaryMinutes) AS sedentary_minutes
FROM daily_activity
GROUP BY DATENAME(weekday, [date]);

-- B. Overall Average Time Spent per Activity
SELECT 
    AVG(VeryActiveMinutes) AS act_min,
    AVG(FairlyActiveMinutes) AS fair_min,
    AVG(LightlyActiveMinutes) AS lit_min,
    AVG(SedentaryMinutes) AS sed_min
FROM daily_activity;

-- C. Hourly Step Trends
SELECT 
    DATEPART(hour, [time]) AS hour,
    AVG(StepTotal) AS average_step
FROM hourly_steps
GROUP BY DATEPART(hour, [time])
ORDER BY hour;

-- D. Hourly Calories vs Steps
SELECT 
    DATEPART(hour, c.[time]) AS hour,
    AVG(c.Calories) AS avg_calories,
    AVG(s.StepTotal) AS avg_steps
FROM hour_calories c
JOIN hourly_steps s 
    ON c.ID = s.ID AND c.[time] = s.[time]
GROUP BY DATEPART(hour, c.[time])
ORDER BY hour;

-- E. Steps vs Sleep Metrics
SELECT 
    ID,
    AVG(sleeptime) AS avg_sleep_minutes,
    AVG(bedtime) AS avg_bed_minutes,
    AVG(bedtime) - AVG(sleeptime) AS avg_time_awake,
    AVG(steps) AS avg_daily_steps
FROM sleep_record
GROUP BY ID;

-- F. Lifestyle Info Per User
SELECT * FROM lifestyle_data;

-- G. Frequency Category Per User
SELECT * FROM user_type;
