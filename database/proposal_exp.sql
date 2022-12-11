SELECT proposal.PROPOSAL_ID, 
	proposal.PROPOSAL_NUMBER AS [Proposal Number], 
	proposal.TITLE AS [Proposal Title], 
	CStr([last_nm] & ", " & [first_nm]) AS PI, 
	-- need A-Number of PI
	unit_1.unit_name AS [PI Home Labor], 
	unit_2.unit_name AS [PI HL Parent], 
	unit.unit_name AS [Lead Unit], 
	unit_3.unit_name AS [Lead Unit Parent], 
	sponsor.sponsor_name AS [Funding Sponsor], 
	proposal.create_timestamp AS [Date Submitted], 
	proposal.requested_start_date_total AS [Requested POP Start], 
	proposal.requested_end_date_total AS [Requested POP End], 
	CCur([total_direct_cost_total]+[total_indirect_cost_total]) AS [Proposal Cost]
FROM 
	(
		(
			(krim_entity_nm_t 
				INNER JOIN 
				(
					(
						(
							( 
								proposal INNER JOIN proposal_persons 
								ON proposal.PROPOSAL_ID = proposal_persons.PROPOSAL_ID
							) 
							INNER JOIN unit 
								ON proposal.LEAD_UNIT_NUMBER = unit.UNIT_NUMBER
						) 
						INNER JOIN sponsor 
							ON proposal.SPONSOR_CODE = sponsor.SPONSOR_CODE
					) 
					INNER JOIN krim_entity_emp_info_t 
						ON proposal_persons.PERSON_ID = krim_entity_emp_info_t.EMP_ID
				) 
				ON krim_entity_nm_t.ENTITY_ID = krim_entity_emp_info_t.ENTITY_ID
			) 
			INNER JOIN unit AS unit_1 
				ON krim_entity_emp_info_t.PRMRY_DEPT_CD = unit_1.UNIT_NUMBER
		) 
		INNER JOIN unit AS unit_2 
			ON unit_1.PARENT_UNIT_NUMBER = unit_2.UNIT_NUMBER
	) 
	INNER JOIN unit AS unit_3 
		ON unit.PARENT_UNIT_NUMBER = unit_3.UNIT_NUMBER
WHERE 
	(
		(( proposal.PROPOSAL_SEQUENCE_STATUS)="ACTIVE") 
		AND ((proposal_persons.CONTACT_ROLE_CODE)="PI")
		-- also need CO-PI info
	)
GROUP BY 
	proposal.PROPOSAL_ID, 
	proposal.PROPOSAL_NUMBER, 
	proposal.TITLE, 
	CStr([last_nm] & ", " & [first_nm]), 
	unit_1.unit_name, 
	unit_2.unit_name, 
	unit.unit_name, 
	unit_3.unit_name, 
	sponsor.sponsor_name, 
	proposal.create_timestamp, 
	proposal.requested_start_date_total, 
	proposal.requested_end_date_total, 
	CCur([total_direct_cost_total]+[total_indirect_cost_total]);
