# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

templates = ModuleTemplate.create(
	[
		# Template 0
		{ 
			name: 'Lipids',
			file: 'lipid',
			javascript_model: 'Lipid'
			
			#k, consume, dna
		},
		
		# Template 1
		{
			name: 'DNA',
			file: 'dna',
			javascript_model: 'DNA'
			
			#k, consume
		},
		
		# Template 2
		{
			name: 'Metabolism Enzyme',
			file: 'metabolism',
			javascript_model: 'Metabolism'
			#k, k_m, k_d, v, orig, dest, dna
		},
		
		# Template 3
		{
			name: 'Protein',
			file: 'protein',
			javascript_model: 'Protein'
			#k, k_d, dna, substrate
		},
		
		# Template 4
		{
			name: 'Substrate',
			file: 'substrate',
			javascript_model: 'Substrate'
			#placement, supply
		},
		
		# Template 5
		{
			name: 'Transporter',
			file: 'transporter',
			javascript_model: 'Transporter'
			#k, k_tr, k_m, orig, dest, dna,	consume
		},
		
		# Template 6
		{
			name: 'Cell growth',
			file: 'cellgrowth',
			javascript_model: 'CellGrowth'
			#consume, #infrastructure
		}
	]
)

parameters = ModuleParameter.create(
	[
	
		# parameter 0
		{ 
			key: 'k', 
			module_template_id: templates.at(0).id
			#Lipid
		}, 
		
		# parameter 1
		{ 
			key: 'consume', 
			module_template_id: templates.at(0).id 
			#Lipid
		},
		
		# parameter 2
		{
			key: 'dna', 
			module_template_id: templates.at(0).id 
			#Lipid
		},
		
		# parameter 3
		{ 
			key: 'k', 
			module_template_id: templates.at(1).id
			#DNA
		}, 
		
		# parameter 4
		{ 
			key: 'consume', 
			module_template_id: templates.at(1).id 
			#DNA
		},
		
		# parameter 5
		{ 
			key: 'k', 
			module_template_id: templates.at(2).id
			#Metabolism
		}, 
		
		# parameter 6
		{ 
			key: 'k_m', 
			module_template_id: templates.at(2).id 
			#Metabolism
		},
		
		# parameter 7
		{ 
			key: 'k_d', 
			module_template_id: templates.at(2).id 
			#Metabolism
		},
		
		# parameter 8
		{ 
			key: 'v', 
			module_template_id: templates.at(2).id 
			#Metabolism
		},
		
		# parameter 9
		{ 
			key: 'dna', 
			module_template_id: templates.at(2).id 
			#Metabolism
		},
		
		# parameter 10
		{ 
			key: 'orig', 
			module_template_id: templates.at(2).id 
			#Metabolism
		},
		
		# parameter 11
		{ 
			key: 'dest', 
			module_template_id: templates.at(2).id 
			#Metabolism
		},
		
		# parameter 12
		{ 
			key: 'dna', 
			module_template_id: templates.at(3).id 
			#Protein
		},
		
		# parameter 13
		{ 
			key: 'k', 
			module_template_id: templates.at(3).id 
			#Protein
		},
		
		# parameter 14
		{ 
			key: 'substrate', 
			module_template_id: templates.at(3).id 
			#Protein
		},
		
		# parameter 15
		{ 
			key: 'placement', 
			module_template_id: templates.at(4).id 
			#Substrate
		},
		
		# parameter 16
		{ 
			key: 'supply', 
			module_template_id: templates.at(4).id 
			#Substrate
		},
		
		# parameter 17
		{ 
			key: 'k', 
			module_template_id: templates.at(5).id 
			#Transporter
		},
		
		# parameter 18
		{ 
			key: 'k_tr', 
			module_template_id: templates.at(5).id 
			#Transporter
		},
		
		# parameter 19
		{ 
			key: 'k_m', 
			module_template_id: templates.at(5).id 
			#Transporter
		},
		
		# parameter 20
		{ 
			key: 'orig', 
			module_template_id: templates.at(5).id 
			#Transporter
		},
		
		# parameter 21
		{ 
			key: 'dest', 
			module_template_id: templates.at(5).id 
			#Transporter
		},
		
		# parameter 22
		{ 
			key: 'dna', 
			module_template_id: templates.at(5).id 
			#Transporter
		},
		
		# parameter 23
		{ 
			key: 'consume', 
			module_template_id: templates.at(5).id 
			#Transporter
		},
		
		# parameter 22
		{ 
			key: 'consume', 
			module_template_id: templates.at(6).id 
			#CellGrowth
		},
		
		# parameter 23
		{ 
			key: 'infrastructure', 
			module_template_id: templates.at(6).id 
			#CellGrowth
		},
				
	]
)