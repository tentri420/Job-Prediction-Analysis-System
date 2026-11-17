import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import plotly.express as px
from datetime import datetime
import seaborn as sns
import streamlit as st


# Read CSV file as dataframe:
df = pd.read_csv("pacement_clean_feat_data.csv")

# DASHBOARD FEATURES:
    
# FILTER:
# Filter Function:
def dash_fea():
    col1,col2 = st.columns(2)
    with col1:
        k_dept=st.selectbox("**Degree Specialization**",["All"]+sorted(df['degree_specialization'].dropna().unique().tolist()))
    with col2:
        k_gender=st.selectbox("**Gender**",["All"]+sorted(df['gender'].dropna().unique().tolist()))
    filtered_df=df.copy()

    if k_dept != "All":
            filtered_df = filtered_df[filtered_df['degree_specialization'] == k_dept]
    if k_gender != "All":
            filtered_df = filtered_df[filtered_df['gender'] == k_gender]
    
# SIDEBAR FUNCTION:
    st.sidebar.markdown(
                    "<h1 style='color:red; font-family:Arial; text-align:center; font-weight: bold; font-style: bold;'>"f"Total Candidates 🧑‍💼 <br>{len(filtered_df):,}""</h1>",
                    unsafe_allow_html=True
                    )
    st.divider()
# Placement Rate: depends on the number of candidate get placed i.e., through status column
# st.metric('Placement Rate',f'{((filtered_df['interview_Score'].mean())*100):,.2f}')
    placement_rate = ((filtered_df["status"] == "Placed").sum()/ len(filtered_df)) * 100

    st.sidebar.markdown(
                    "<h2 style='color:green; font-family:Arial; text-align:center; font-weight: bold; font-style: italic; font-size: 25px;'>"f"Placement Rate 📈<br> {placement_rate:.2f} %""</h2>",
                    unsafe_allow_html=True 
                    )

# METIC TO SHOW IN CENTER:
   
    st.markdown("""
<style>
[data-testid="stMetricLabel"] {
    color: #3498DB;
    font-size: 18px;
    font-weight: bold;
    justify-content: center;
}

[data-testid="stMetricValue"] {
    color: #2ECC71;
    font-size: 30px;
    font-weight: bold;
    justify-content: center;
    text-align: center;
}
</style>
""", unsafe_allow_html=True)
# High Risk Candidate Percentage:

    df_high_risk=filtered_df[filtered_df['placement_prob'] < 25.00]
    
    high_risk_percentage = (
    len(df_high_risk) / len(filtered_df)
) * 100 if len(filtered_df) > 0 else 0
    st.sidebar.metric("**Percentage of Risk Candidate**",f"{high_risk_percentage}%")

# Acceptance and Drop out Rate:
# ASSUMING DROP CANDIDATES:

    drop_df=df[(df['status']=='Not Placed')&(df['placement_cat']=='High')&(df['job_role_match']=='Matched')&(df['relevant_experience']=='Relevant')&(df['competition_level']=='High')&(df['interview_Score_cat']!='Average')][['interview_Score_cat','experience_cat']].value_counts().reset_index(name='no_of_cand')
    drop_out=drop_df['no_of_cand'].sum()

# 1. FIND TOT OFFER
    tot_offer=(df['status']=='Placed').sum() + drop_out
    col1,col2=st.columns(2)
# 2. Accepted Rate:
    with col1:
        accepted_offer= round((df['status']=='Placed').sum() / tot_offer,2)*100
        st.sidebar.metric("**Accepted Rate**",f"{accepted_offer}%")
# 3. Drop Out Rate:
    with col2:
        drop_out_offer= round(drop_out/tot_offer,2)*100
        st.sidebar.metric("**Drop Out Rate**",f"{drop_out_offer}%")

# CHART PERF FOR AVG(interview score & skill match)
   # CALC AVG: 
    df_avg = (
    filtered_df[['interview_Score', 'skills_match_percentage']]
    .mean()
    .round(2)
    .reset_index()
)

    df_avg.columns = ['Performance', 'Average Score']

    fig = px.bar(
    df_avg,
    x='Performance',
    y='Average Score',
    text='Average Score',
    color='Performance',
    )

    fig.update_traces(textposition='outside')
    fig.update_layout(showlegend=False)
    st.subheader('Average Interview and Skills Match Score')
    st.plotly_chart(fig, use_container_width=True)  
    
# COMPANY TIER & DEGREE:
    df_pivot = pd.crosstab(
    filtered_df['degree_specialization'],
    filtered_df['company_tier']
)

    fig = px.imshow(
    df_pivot,
    text_auto=True,
    color_continuous_scale='peach',
)
    st.subheader('Degree Specialization vs Company Tier')
    st.plotly_chart(fig, use_container_width=True)

# COMPANY TIER:
    df_tier = (
    filtered_df.groupby('company_tier')
    .agg(
        total_candidates=('status', 'count'),
        placed=('status', lambda x: (x == 'Placed').sum())
    )
    .reset_index()
)

    df_tier['placement_rate'] = (
    df_tier['placed'] / df_tier['total_candidates'] * 100
).round(2)

#STACKBAR CHART:
    fig = px.histogram(
    filtered_df,
    x='company_tier',
    color='status',
    barmode='stack',
    text_auto=True, 
    color_discrete_sequence=['pink', 'yellow']
)
    st.subheader('Placement Status by Company Tier')
    st.plotly_chart(fig, use_container_width=True)

# DASH - TITLE:

st.html("""
<h2 style="
    background: #172554;
    color: white;
    padding: 25px;
    border-radius: 12px;
    text-align: center;
    font-family: Arial, sans-serif;
    font-size: 40px;
">
    Job Prediction Analysis
</h2>
""")

st.markdown("<h2 style='color:red; font-family:Georgia; text-align:left;'> 💼 Dashboard</h2>",
                   unsafe_allow_html=True )
st.subheader("**🙏 Welcome!**")
dash_fea()