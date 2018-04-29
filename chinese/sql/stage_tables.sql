DROP TABLE maxval_chinese.maxval_chinese_stage;
CREATE TABLE maxval_chinese.maxval_chinese_stage(
  id serial primary key
, CaseId integer
, CaseNo varchar(255)
, Court varchar(255)
, Province varchar(255)
, City varchar(255)
, CountryCode varchar(255)
, CountryName varchar(255)
, FiledDate varchar(255)
, ClosedDate varchar(255)
, NatureofSuit varchar(255)
, NatureofSuit_Subtype varchar(255)
, CaseCategory varchar(255)
, DisputeLevel varchar(255)
, CaseType varchar(255)
, DocumentType varchar(255)
, Industry varchar(255)
, Plaintiff varchar(255)
, PlaintiffLawfirm varchar(255)
, AgentPlaintiff varchar(255)
, Defendant varchar(255)
, DefendantLawfirm varchar(255)
, AgentDefendant varchar(255)
, JudgeName varchar(255)
, IsFinalJudgement varchar(255)
, DetailifLost varchar(255)
, Typeofadministrativedispute varchar(255)
, DecisionOfPRB varchar(255)
, Appellant varchar(255)
, DamagesType varchar(255)
, DamagesClaimed varchar(255)
, DamagesAwarded varchar(255)
, InjunctionClaimed varchar(255)
, InjunctionAwarded varchar(255)
, IsRecognitionRights varchar(255)
, ValidityChallenged varchar(255)
, PlaintinffAttitude varchar(255)
, CourtAttitude varchar(255)
, Jurisdition varchar(255)
, JurisditionAccepted varchar(255)
, ClaimCost varchar(255)
, AwardedCost varchar(255)
, ApologyClaimed varchar(255)
, ApologyAwarded varchar(255)
, IsModifiedDecision varchar(255)
, FirstInstanceCompensationAwarded varchar(255)
, FirstInstanceCostAwarded varchar(255)
, FirstInstanceInjunctionClaimed varchar(255)
, FirstInstanceInjunctionAwarded varchar(255)
, FirstInstanceApologyClaimed varchar(255)
, FirstInstanceApologyAwarded varchar(255)
, FirstInstanceDamagesClaimed varchar(255)
, FirstInstanceCostClaimed varchar(255)
, FirstInstanceOutcome varchar(255)
, SecondDamageAward varchar(255)
, SecondCostAward varchar(255)
, SecondInstanceInjunctionAwarded varchar(255)
, SecondInstanceApologyAwarded varchar(255)
, SecondInstanceOutcome varchar(255));
DROP TABLE maxval_chinese.maxval_ch_lit_pats_map_stg;
CREATE TABLE maxval_chinese.maxval_ch_lit_pats_map_stg(
  id serial primary key
, PatentNumber varchar(255)
, Inventor varchar(255)
, Title varchar(255)
, FAMILYID varchar(255)
, UCID varchar(255)
, FAMILY varchar(255)
, CASEID varchar(255));

create table maxval_chinese.ch_patry_types(
id serial primary key ,
party_type varchar(255) ,
created_at TIMESTAMP DEFAULT clock_timestamp(),
updated_at TIMESTAMP 
);

INSERT INTO maxval_chinese.chinese_industries (chinese_industry_name , ch_lit_id)
select value as title , 
(SELECT id from maxval_chinese.chinese_lits where ch_caseid = b.join_key) as ch_lit_id
FROM maxval_chinese.clean_string_to_array_records_to_populate_nulls_with_not_null((select industry FROM maxval_chinese.maxval_chinese_stage WHERE caseid = 51601),51601) b ;

INSERT INTO maxval_chinese.ch_lit_outcomedetails(ch_lit_id,ch_isfinaljudgement,ch_detailiflost,ch_typeofadministrativedispute,ch_decisionofprb,ch_appellant,ch_damagestype,ch_damagesclaimed,ch_damagesawarded,ch_injunctionclaimed,ch_injunctionawarded,ch_isrecognitionrights,ch_validitychallenged,ch_plaintinffattitude,ch_courtattitude,ch_jurisdition,ch_jurisditionaccepted,ch_claimcost,ch_awardedcost,ch_apologyclaimed,ch_apologyawarded,ch_ismodifieddecision)
select (select id from maxval_chinese.chinese_lits WHERE ch_caseid = stg.caseid
),case when trim(IsFinalJudgement)='-' then null else trim(IsFinalJudgement)::boolean end  ,
	DetailifLost,Typeofadministrativedispute,DecisionOfPRB,Appellant,DamagesType,DamagesClaimed,DamagesAwarded,InjunctionClaimed,InjunctionAwarded,
case when trim(IsRecognitionRights)='-' then null else trim(IsRecognitionRights)::boolean end   
,ValidityChallenged,PlaintinffAttitude,CourtAttitude,Jurisdition,JurisditionAccepted,ClaimCost,AwardedCost,ApologyClaimed,ApologyAwarded,
case when trim(IsModifiedDecision)='-' then null else trim(IsModifiedDecision)::boolean end   
FROM maxval_chinese.maxval_chinese_stage stg;

INSERT INTO maxval_chinese.ch_lit_firstinstanceoutcomedetails (ch_lit_id,ch_firstinstancecompensationawarded,ch_firstinstancecostawarded,ch_firstinstanceinjunctionclaimed,ch_firstinstanceinjunctionawarded,ch_firstinstanceapologyclaimed,ch_firstinstanceapologyawarded,ch_firstinstancedamagesclaimed,ch_firstinstancecostclaimed,ch_firstinstanceoutcome)
SELECT (select id from maxval_chinese.chinese_lits WHERE ch_caseid = stg.caseid),
			 firstinstancecompensationawarded,
			 firstinstancecostawarded,
			 firstinstanceinjunctionclaimed,
			 firstinstanceinjunctionawarded,
       firstinstanceapologyclaimed,
       firstinstanceapologyawarded,
       firstinstancedamagesclaimed,
       firstinstancecostclaimed,
       firstinstanceoutcome 
FROM   maxval_chinese.maxval_chinese_stage stg;

INSERT INTO maxval_chinese.ch_lit_secondinstanceoutcomedetails (ch_lit_id,ch_seconddamageaward,ch_secondcostaward,ch_secondinstanceinjunctionawarded,ch_secondinstanceapologyawarded,ch_secondinstanceoutcome)
SELECT (select id from maxval_chinese.chinese_lits WHERE ch_caseid = stg.caseid),
			 seconddamageaward,secondcostaward,secondinstanceinjunctionawarded,secondinstanceapologyawarded,secondinstanceoutcome
FROM   maxval_chinese.maxval_chinese_stage stg;


INSERT INTO maxval_chinese.ch_lit_pats_map(ch_lit_id , patentnumber,inventor,title,ifi_ucid , ifi_familyid , ifi_family_members )
select (select id from maxval_chinese.chinese_lits where ch_caseid = stg.caseid::INT), 
	patentnumber , inventor , title , ucid , familyid::int ,string_to_array(family,', ') 
FROM maxval_chinese.maxval_ch_lit_pats_map_stg stg ;
