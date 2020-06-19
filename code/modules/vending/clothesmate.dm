//DON'T FORGET TO CHANGE THE REFILL SIZE IF YOU CHANGE THE MACHINE'S CONTENTS!
/obj/machinery/vending/clothing
	name = "ClothesMate" //renamed to make the slogan rhyme
	desc = "A vending machine for clothing."
	icon_state = "clothes"
	icon_deny = "clothes-deny"
	product_slogans = "Dress for success!;Prepare to look swagalicious!;Look at all this swag!;Why leave style up to fate? Use the ClothesMate!"
	vend_reply = "Thank you for using the ClothesMate!"
	products = list(/obj/item/clothing/head/beanie = 3,
		            /obj/item/clothing/head/beanie/black = 3,
		            /obj/item/clothing/head/beanie/red = 3,
		            /obj/item/clothing/head/beanie/green = 3,
		            /obj/item/clothing/head/beanie/darkblue = 3,
		            /obj/item/clothing/head/beanie/purple = 3,
		            /obj/item/clothing/head/beanie/yellow = 3,
		            /obj/item/clothing/head/beanie/orange = 3,
		            /obj/item/clothing/head/beanie/cyan = 3,
		            /obj/item/clothing/head/beanie/christmas = 3,
		            /obj/item/clothing/head/beanie/striped = 3,
		            /obj/item/clothing/head/beanie/stripedred = 3,
		            /obj/item/clothing/head/beanie/stripedblue = 3,
		            /obj/item/clothing/head/beanie/stripedgreen = 3,
					/obj/item/clothing/head/beanie/rasta = 3,
					/obj/item/clothing/head/kippah = 3,
					/obj/item/clothing/head/taqiyahred = 3,
		            /obj/item/clothing/gloves/fingerless = 2,
					/obj/item/clothing/gloves/color/black = 2,
					/obj/item/clothing/gloves/color/orange = 2,
					/obj/item/clothing/gloves/color/red = 2,
					/obj/item/clothing/gloves/color/rainbow = 2,
					/obj/item/clothing/gloves/color/blue = 2,
					/obj/item/clothing/gloves/color/purple = 2,
		            /obj/item/clothing/neck/scarf/pink = 3,
		            /obj/item/clothing/neck/scarf/red = 3,
		            /obj/item/clothing/neck/scarf/green = 3,
		            /obj/item/clothing/neck/scarf/darkblue = 3,
		            /obj/item/clothing/neck/scarf/purple = 3,
		            /obj/item/clothing/neck/scarf/yellow = 3,
		            /obj/item/clothing/neck/scarf/orange = 3,
		            /obj/item/clothing/neck/scarf/cyan = 3,
		            /obj/item/clothing/neck/scarf = 3,
		            /obj/item/clothing/neck/scarf/black = 3,
		            /obj/item/clothing/neck/scarf/zebra = 3,
		            /obj/item/clothing/neck/scarf/christmas = 3,
		            /obj/item/clothing/neck/stripedredscarf = 3,
		            /obj/item/clothing/neck/stripedbluescarf = 3,
		            /obj/item/clothing/neck/stripedgreenscarf = 3,
		            /obj/item/clothing/neck/tie/blue = 3,
		            /obj/item/clothing/neck/tie/red = 3,
		            /obj/item/clothing/neck/tie/black = 3,
		            /obj/item/clothing/neck/tie/horrible = 3,
		            /obj/item/storage/belt/fannypack = 3,
		            /obj/item/storage/belt/fannypack/blue = 3,
		            /obj/item/storage/belt/fannypack/red = 3,
		            /obj/item/clothing/under/misc/overalls = 2,
		            /obj/item/clothing/under/pants/jeans = 2,
		            /obj/item/clothing/under/pants/classicjeans = 2,
		            /obj/item/clothing/under/pants/camo = 2,
		            /obj/item/clothing/under/pants/blackjeans = 2,
		            /obj/item/clothing/under/pants/khaki = 2,
		            /obj/item/clothing/under/pants/white = 2,
		            /obj/item/clothing/under/pants/red = 2,
		            /obj/item/clothing/under/pants/black = 2,
		            /obj/item/clothing/under/pants/tan = 2,
		            /obj/item/clothing/under/pants/track = 2,
		            /obj/item/clothing/shoes/sneakers/black = 4,
		            /obj/item/clothing/head/wig/natural  = 4,
		            /obj/item/clothing/under/dress/skirt/plaid = 2,
		            /obj/item/clothing/under/dress/skirt/plaid/blue = 2,
		            /obj/item/clothing/under/dress/skirt/plaid/green = 2,
		            /obj/item/clothing/under/dress/skirt/plaid/purple = 2,
		            /obj/item/clothing/under/dress/skirt = 2,
		            /obj/item/clothing/under/dress/skirt/blue = 2,
		            /obj/item/clothing/under/dress/skirt/red = 2,
		            /obj/item/clothing/under/dress/skirt/purple = 2,
		            /obj/item/clothing/under/suit/white/skirt = 2,
		            /obj/item/clothing/under/rank/captain/suit/skirt = 2,
		            /obj/item/clothing/under/rank/civilian/head_of_personnel/suit/skirt = 2,
		            /obj/item/clothing/suit/jacket = 2,
		            /obj/item/clothing/suit/jacket/puffer/vest = 2,
		            /obj/item/clothing/suit/jacket/puffer = 2,
		            /obj/item/clothing/suit/jacket/letterman = 2,
		            /obj/item/clothing/suit/jacket/letterman_red = 2,
		            /obj/item/clothing/glasses/regular = 2,
		            /obj/item/clothing/glasses/regular/jamjar = 1,
		            /obj/item/clothing/glasses/orange = 1,
		            /obj/item/clothing/glasses/red = 1,
		            /obj/item/clothing/under/suit/navy = 1,
		            /obj/item/clothing/under/suit/black_really = 1,
		            /obj/item/clothing/under/suit/burgundy = 1,
		            /obj/item/clothing/under/suit/charcoal = 1,
		            /obj/item/clothing/under/suit/white = 1,
		            /obj/item/clothing/under/suit/sl = 1,
		            /obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/head/that = 1,
		            /obj/item/clothing/head/fedora = 1,
		            /obj/item/clothing/glasses/monocle = 1,
		            /obj/item/clothing/head/sombrero = 1,
		            /obj/item/clothing/suit/poncho = 1,
		            /obj/item/clothing/under/costume/kilt = 1,
		            /obj/item/clothing/under/dress/sundress = 1,
		            /obj/item/clothing/under/dress/striped = 1,
		            /obj/item/clothing/under/dress/sailor = 1,
		            /obj/item/clothing/under/dress/redeveninggown = 1,
		            /obj/item/clothing/under/dress/blacktango = 1,
		            /obj/item/clothing/suit/ianshirt = 1,
		            /obj/item/clothing/shoes/laceup = 2,
		            /obj/item/clothing/shoes/sandal = 2,
		            /obj/item/clothing/shoes/cowboy = 2,
		            /obj/item/clothing/shoes/cowboy/white = 2,
		            /obj/item/clothing/shoes/cowboy/black = 2,
		            /obj/item/clothing/suit/jacket/miljacket = 1,
		            /obj/item/clothing/suit/apron/purple_bartender = 2,
		            /obj/item/clothing/under/rank/civilian/bartender/purple = 2,
		            /obj/item/clothing/suit/toggle/suspenders/blue = 2,
		            /obj/item/clothing/suit/toggle/suspenders/gray = 2)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 1,
					  /obj/item/clothing/under/syndicate/tacticool/skirt = 1,
		              /obj/item/clothing/mask/balaclava = 1,
		              /obj/item/clothing/head/ushanka = 1,
		              /obj/item/clothing/under/costume/soviet = 1,
		              /obj/item/storage/belt/fannypack/black = 2,
		              /obj/item/clothing/suit/jacket/letterman_syndie = 1,
		              /obj/item/clothing/under/costume/jabroni = 1,
		              /obj/item/clothing/suit/vapeshirt = 1,
		              /obj/item/clothing/under/costume/geisha = 1)
	premium = list(/obj/item/clothing/under/suit/checkered = 1,
		           /obj/item/clothing/head/mailman = 1,
		           /obj/item/clothing/under/misc/mailman = 1,
		           /obj/item/clothing/suit/jacket/leather = 1,
		           /obj/item/clothing/suit/jacket/leather/overcoat = 1,
		           /obj/item/clothing/under/pants/mustangjeans = 1,
		           /obj/item/clothing/neck/necklace/dope = 3,
		           /obj/item/clothing/suit/jacket/letterman_nanotrasen = 1,
		           /obj/item/instrument/piano_synth/headphones/spacepods = 1)
	refill_canister = /obj/item/vending_refill/clothing
	default_price = 60
	extra_price = 120
	payment_department = NO_FREEBIES
	light_mask = "wardrobe-light-mask"
	light_color = "#00FF00"

/obj/machinery/vending/clothing/canLoadItem(obj/item/I,mob/user)
	return (I.type in products)

/obj/item/vending_refill/clothing
	machine_name = "ClothesMate"
	icon_state = "refill_clothes"

/obj/machinery/vending/clothing/jumpsuits
	name = "ThreadStore"
	desc = "A vending machine for jumpsuits and casual clothing."
	products = list(/obj/item/clothing/under/color/black = 10,
					/obj/item/clothing/under/color/jumpskirt/black = 10,
					/obj/item/clothing/under/color/grey = 10,
					/obj/item/clothing/under/color/jumpskirt/grey = 10,
					/obj/item/clothing/under/color/blue = 10,
					/obj/item/clothing/under/color/jumpskirt/blue = 10,
					/obj/item/clothing/under/color/green = 10,
					/obj/item/clothing/under/color/jumpskirt/green = 10,
					/obj/item/clothing/under/color/orange = 10,
					/obj/item/clothing/under/color/jumpskirt/orange = 10,
					/obj/item/clothing/under/color/pink = 10,
					/obj/item/clothing/under/color/jumpskirt/pink = 10,
					/obj/item/clothing/under/color/red = 10,
					/obj/item/clothing/under/color/jumpskirt/red = 10,
					/obj/item/clothing/under/color/white = 10,
					/obj/item/clothing/under/color/jumpskirt/white = 10,
					/obj/item/clothing/under/color/yellow = 10,
					/obj/item/clothing/under/color/jumpskirt/yellow = 10,
					/obj/item/clothing/under/color/darkblue = 10,
					/obj/item/clothing/under/color/jumpskirt/darkblue = 10,
					/obj/item/clothing/under/color/teal = 10,
					/obj/item/clothing/under/color/jumpskirt/teal = 10,
					/obj/item/clothing/under/color/lightpurple = 10,
					/obj/item/clothing/under/color/jumpskirt/lightpurple = 10,
					/obj/item/clothing/under/color/darkgreen = 10,
					/obj/item/clothing/under/color/jumpskirt/darkgreen = 10,
					/obj/item/clothing/under/color/lightbrown = 10,
					/obj/item/clothing/under/color/jumpskirt/lightbrown = 10,
					/obj/item/clothing/under/color/brown = 10,
					/obj/item/clothing/under/color/jumpskirt/brown = 10,
					/obj/item/clothing/under/color/maroon = 10,
					/obj/item/clothing/under/color/jumpskirt/maroon = 10,
					/obj/item/clothing/under/color/rainbow = 10,
					/obj/item/clothing/under/color/jumpskirt/rainbow = 10,
					/obj/item/clothing/under/misc/pj/red = 10,
					/obj/item/clothing/under/misc/pj/blue = 10,
					/obj/item/clothing/under/misc/psyche = 10,
					/obj/item/clothing/under/misc/durathread/cosmetic = 10,
					/obj/item/clothing/under/pants/classicjeans = 10,
					/obj/item/clothing/under/pants/mustangjeans = 10,
					/obj/item/clothing/under/pants/blackjeans = 10,
					/obj/item/clothing/under/pants/youngfolksjeans = 10,
					/obj/item/clothing/under/pants/white = 10,
					/obj/item/clothing/under/pants/red = 10,
					/obj/item/clothing/under/pants/black = 10,
					/obj/item/clothing/under/pants/tan = 10,
					/obj/item/clothing/under/pants/track = 10,
					/obj/item/clothing/under/pants/jeans = 10,
					/obj/item/clothing/under/pants/khaki = 10,
					/obj/item/clothing/under/pants/camo = 10,
					/obj/item/clothing/under/shorts = 10,
					/obj/item/clothing/under/shorts/red = 10,
					/obj/item/clothing/under/shorts/green = 10,
					/obj/item/clothing/under/shorts/blue = 10,
					/obj/item/clothing/under/shorts/black = 10,
					/obj/item/clothing/under/shorts/grey = 10,
					/obj/item/clothing/under/shorts/purple = 10,
					/obj/item/clothing/under/dress/sundress = 10,
					/obj/item/clothing/under/dress/skirt = 10,
					/obj/item/clothing/under/dress/skirt/blue = 10,
					/obj/item/clothing/under/dress/skirt/red = 10,
					/obj/item/clothing/under/dress/skirt/purple = 10,
					/obj/item/clothing/under/dress/skirt/plaid = 10,
					/obj/item/clothing/under/dress/skirt/plaid/blue = 10,
					/obj/item/clothing/under/dress/skirt/plaid/purple = 10,
					/obj/item/clothing/under/dress/skirt/plaid/green = 10)
	contraband = list()
	premium = list()

/obj/machinery/vending/clothing/jackets
	name = "JacketHub"
	desc = "A vending machine for jackets and overwear."
	products = list(/obj/item/clothing/suit/apron/overalls = 10,
					/obj/item/clothing/suit/poncho = 10,
					/obj/item/clothing/suit/poncho/green = 10,
					/obj/item/clothing/suit/poncho/red = 10,
					/obj/item/clothing/suit/hooded/carp_costume = 10,
					/obj/item/clothing/suit/hooded/ian_costume = 10,
					/obj/item/clothing/suit/hooded/bee_costume = 10,
					/obj/item/clothing/suit/security/officer/russian = 10,
					/obj/item/clothing/suit/ianshirt = 10,
					/obj/item/clothing/suit/nerdshirt = 10,
					/obj/item/clothing/suit/vapeshirt = 10,
					/obj/item/clothing/suit/striped_sweater = 10,
					/obj/item/clothing/suit/jacket = 10,
					/obj/item/clothing/suit/jacket/leather = 10,
					/obj/item/clothing/suit/jacket/leather/overcoat = 10,
					/obj/item/clothing/suit/jacket/puffer = 10,
					/obj/item/clothing/suit/jacket/puffer/vest = 10,
					/obj/item/clothing/suit/jacket/miljacket = 10,
					/obj/item/clothing/suit/jacket/letterman = 10,
					/obj/item/clothing/suit/jacket/letterman_red = 10,
					/obj/item/clothing/suit/jacket/letterman_syndie = 10,
					/obj/item/clothing/suit/jacket/letterman_nanotrasen = 10,
					/obj/item/clothing/suit/changshan_red = 10,
					/obj/item/clothing/suit/changshan_blue = 10,
					/obj/item/clothing/suit/cheongsam_red = 10,
					/obj/item/clothing/suit/cheongsam_blue = 10,
					/obj/item/clothing/suit/toggle/suspenders/blue = 10,
					/obj/item/clothing/suit/toggle/suspenders/gray = 10,
					/obj/item/clothing/suit/hawaiian = 10)
	contraband = list()
	premium = list()

/obj/machinery/vending/clothing/accessories
	name = "All Accessorize"
	desc = "A vending machine for accessories."
	products = list(/obj/item/clothing/glasses/eyepatch = 10,
					/obj/item/clothing/glasses/monocle = 10,
					/obj/item/clothing/glasses/regular = 10,
					/obj/item/clothing/glasses/regular/jamjar = 10,
					/obj/item/clothing/glasses/regular/hipster = 10,
					/obj/item/clothing/glasses/regular/circle = 10,
					/obj/item/clothing/glasses/sunglasses = 10,
					/obj/item/clothing/glasses/sunglasses/big = 10,
					/obj/item/clothing/glasses/orange = 10,
					/obj/item/clothing/glasses/red = 10,
					/obj/item/clothing/gloves/color/black = 10,
					/obj/item/clothing/gloves/color/orange = 10,
					/obj/item/clothing/gloves/color/red = 10,
					/obj/item/clothing/gloves/color/rainbow = 10,
					/obj/item/clothing/gloves/color/blue = 10,
					/obj/item/clothing/gloves/color/purple = 10,
					/obj/item/clothing/gloves/color/green = 10,
					/obj/item/clothing/gloves/color/grey = 10,
					/obj/item/clothing/gloves/color/light_brown = 10,
					/obj/item/clothing/gloves/color/brown = 10,
					/obj/item/clothing/gloves/color/white = 10,
					/obj/item/clothing/gloves/fingerless = 10,
					/obj/item/clothing/gloves/color/plasmaman = 10,
					/obj/item/clothing/gloves/color/plasmaman/black = 10,
					/obj/item/clothing/gloves/color/plasmaman/white = 10,
					/obj/item/clothing/head/beanie = 10,
					/obj/item/clothing/head/beanie/black = 10,
					/obj/item/clothing/head/beanie/green = 10,
					/obj/item/clothing/head/beanie/darkblue = 10,
					/obj/item/clothing/head/beanie/purple = 10,
					/obj/item/clothing/head/beanie/orange = 10,
					/obj/item/clothing/head/beanie/yellow = 10,
					/obj/item/clothing/head/beanie/cyan = 10,
					/obj/item/clothing/head/beanie/christmas = 10,
					/obj/item/clothing/head/beanie/striped = 10,
					/obj/item/clothing/head/beanie/stripedblue = 10,
					/obj/item/clothing/head/beanie/stripedgreen = 10,
					/obj/item/clothing/head/beanie/stripedred = 10,
					/obj/item/clothing/head/beanie/durathread/cosmetic = 10,
					/obj/item/clothing/head/beanie/waldo = 10,
					/obj/item/clothing/head/beanie/rasta = 10,
					/obj/item/clothing/head/beret = 10,
					/obj/item/clothing/head/beret/black = 10,
					/obj/item/clothing/head/beret/durathread/cosmetic = 10,
					/obj/item/clothing/head/frenchberet = 10,
					/obj/item/clothing/head/kitty = 10,
					/obj/item/clothing/head/wig = 10,
					/obj/item/clothing/head/wig/natural = 10,
					/obj/item/clothing/head/that = 10,
					/obj/item/clothing/head/canada = 10,
					/obj/item/clothing/head/rabbitears = 10,
					/obj/item/clothing/head/bowler = 10,
					/obj/item/clothing/head/fedora = 10,
					/obj/item/clothing/head/fedora/white = 10,
					/obj/item/clothing/head/fedora/beige = 10,
					/obj/item/clothing/head/fedora/curator = 10,
					/obj/item/clothing/head/sombrero = 10,
					/obj/item/clothing/head/sombrero/green = 10,
					/obj/item/clothing/head/flatcap = 10,
					/obj/item/clothing/head/soft = 10,
					/obj/item/clothing/head/soft/red = 10,
					/obj/item/clothing/head/soft/blue = 10,
					/obj/item/clothing/head/soft/green = 10,
					/obj/item/clothing/head/soft/yellow = 10,
					/obj/item/clothing/head/soft/grey = 10,
					/obj/item/clothing/head/soft/orange = 10,
					/obj/item/clothing/head/soft/mime = 10,
					/obj/item/clothing/head/soft/purple = 10,
					/obj/item/clothing/head/soft/black = 10,
					/obj/item/clothing/head/soft/rainbow = 10,
					/obj/item/clothing/mask/fakemoustache = 10,
					/obj/item/clothing/mask/fakemoustache/italian = 10,
					/obj/item/clothing/mask/bandana = 10,
					/obj/item/clothing/mask/bandana/black = 10,
					/obj/item/clothing/mask/bandana/blue = 10,
					/obj/item/clothing/mask/bandana/durathread = 10,
					/obj/item/clothing/mask/bandana/gold = 10,
					/obj/item/clothing/mask/bandana/green = 10,
					/obj/item/clothing/mask/bandana/red = 10,
					/obj/item/clothing/mask/bandana/skull = 10,
					/obj/item/clothing/neck/tie = 10,
					/obj/item/clothing/neck/tie/blue = 10,
					/obj/item/clothing/neck/tie/black = 10,
					/obj/item/clothing/neck/tie/detective = 10,
					/obj/item/clothing/neck/tie/horrible = 10,
					/obj/item/clothing/neck/tie/red = 10,
					/obj/item/clothing/neck/scarf = 10,
					/obj/item/clothing/neck/scarf/christmas = 10,
					/obj/item/clothing/neck/scarf/cyan = 10,
					/obj/item/clothing/neck/scarf/darkblue = 10,
					/obj/item/clothing/neck/scarf/green = 10,
					/obj/item/clothing/neck/scarf/orange = 10,
					/obj/item/clothing/neck/scarf/pink = 10,
					/obj/item/clothing/neck/scarf/purple = 10,
					/obj/item/clothing/neck/scarf/red = 10,
					/obj/item/clothing/neck/scarf/yellow = 10,
					/obj/item/clothing/neck/scarf/zebra = 10,
					/obj/item/clothing/neck/stripedredscarf = 10,
					/obj/item/clothing/neck/stripedgreenscarf = 10,
					/obj/item/clothing/neck/stripedbluescarf = 10,
					/obj/item/clothing/neck/necklace/dope = 10,
					/obj/item/clothing/neck/beads = 10,
					/obj/item/clothing/shoes/sneakers/black = 10,
					/obj/item/clothing/shoes/sneakers/brown = 10,
					/obj/item/clothing/shoes/sneakers/green = 10,
					/obj/item/clothing/shoes/sneakers/mime = 10,
					/obj/item/clothing/shoes/sneakers/orange = 10,
					/obj/item/clothing/shoes/sneakers/purple = 10,
					/obj/item/clothing/shoes/sneakers/rainbow = 10,
					/obj/item/clothing/shoes/sneakers/red = 10,
					/obj/item/clothing/shoes/sneakers/white = 10,
					/obj/item/clothing/shoes/sneakers/yellow = 10,
					/obj/item/clothing/shoes/sandal = 10,
					/obj/item/clothing/shoes/jackboots = 10,
					/obj/item/clothing/shoes/laceup = 10,
					/obj/item/clothing/shoes/wheelys = 10,
					/obj/item/clothing/shoes/russian = 10,
					/obj/item/clothing/shoes/cowboy = 10,
					/obj/item/clothing/shoes/cowboy/white = 10,
					/obj/item/clothing/shoes/cowboy/black = 10,
					/obj/item/clothing/shoes/cowboy/fancy = 10,
					/obj/item/clothing/shoes/cookflops = 10)
	contraband = list()
	premium = list()

/obj/machinery/vending/clothing/secretlizard
	name = "Secret Lizard's Secret Shop (of Secrecy)"
	desc = "Yes, that's right! By leaving offerings on this altar (in the form of money) Secret Lizard will trade with you for a variety of weird and wonderful items!"
	product_slogans = "Secret Lizard desires your money, traveller!;I've been in this temple for 50,000 years, the least you can do is buy something!;Please, no human sacrifices... cash will suffice, thank you."
	vend_reply = "Secret Lizard looks forward to your next visit, friend!"
	icon = 'icons/obj/cult.dmi'
	icon_state = "talismanaltar"
	icon_deny = "talismanaltar"
	products = list(/obj/item/clothing/head/helmet/skull = 10,
					/obj/item/clothing/head/helmet/rus_helmet = 10,
					/obj/item/clothing/head/helmet/rus_ushanka = 10,
					/obj/item/clothing/head/helmet/infiltrator = 10,
					/obj/item/clothing/head/drfreezehat = 10,
					/obj/item/clothing/head/pharaoh = 10,
					/obj/item/clothing/head/nemes = 10,
					/obj/item/clothing/head/hardhat/pumpkinhead = 10,
					/obj/item/clothing/head/hardhat/reindeer = 10,
					/obj/item/clothing/head/cardborg = 10,
					/obj/item/clothing/head/bronze = 10,
					/obj/item/clothing/head/jackbros = 10,
					/obj/item/clothing/mask/balaclava = 10,
					/obj/item/clothing/mask/infiltrator = 10,
					/obj/item/clothing/mask/russian_balaclava = 10,
					/obj/item/clothing/mask/gas/syndicate = 10,
					/obj/item/clothing/mask/gas/cyborg = 10,
					/obj/item/clothing/mask/gas/owl_mask = 10,
					/obj/item/clothing/mask/gas/carp = 10,
					/obj/item/clothing/mask/gas/tiki_mask = 10,
					/obj/item/clothing/mask/gas/hunter = 10,
					/obj/item/clothing/mask/mummy = 10,
					/obj/item/clothing/mask/gondola = 10,
					/obj/item/clothing/shoes/combat = 10,
					/obj/item/clothing/shoes/combat/sneakboots = 10,
					/obj/item/clothing/shoes/cult = 10,
					/obj/item/clothing/shoes/cyborg = 10,
					/obj/item/clothing/shoes/griffin = 10,
					/obj/item/clothing/shoes/bronze = 10,
					/obj/item/clothing/shoes/russian = 10,
					/obj/item/clothing/shoes/cowboy/lizard/masterwork = 10,
					/obj/item/clothing/shoes/yakuza = 10,
					/obj/item/clothing/shoes/jackbros = 10,
					/obj/item/clothing/suit/space/hardsuit/engine = 10,
					/obj/item/clothing/suit/space/hardsuit/engine/atmos = 10,
					/obj/item/clothing/suit/space/hardsuit/engine/elite = 10,
					/obj/item/clothing/suit/space/hardsuit/mining = 10,
					/obj/item/clothing/suit/space/hardsuit/syndi = 10,
					/obj/item/clothing/suit/space/hardsuit/syndi/elite = 10,
					/obj/item/clothing/suit/space/hardsuit/syndi/owl = 10,
					/obj/item/clothing/suit/space/hardsuit/wizard = 10,
					/obj/item/clothing/suit/space/hardsuit/medical = 10,
					/obj/item/clothing/suit/space/hardsuit/rd = 10,
					/obj/item/clothing/suit/space/hardsuit/security = 10,
					/obj/item/clothing/suit/space/hardsuit/security/hos = 10,
					/obj/item/clothing/suit/space/hardsuit/swat = 10,
					/obj/item/clothing/suit/space/hardsuit/swat/captain = 10,
					/obj/item/clothing/suit/space/hardsuit/ancient = 10,
					/obj/item/clothing/suit/space/officer = 10,
					/obj/item/clothing/head/helmet/space/beret = 10,
					/obj/item/clothing/suit/space/nasavoid = 10,
					/obj/item/clothing/head/helmet/space/nasavoid = 10,
					/obj/item/clothing/suit/space/santa = 10,
					/obj/item/clothing/head/helmet/space/santahat = 10,
					/obj/item/clothing/suit/space/pirate = 10,
					/obj/item/clothing/head/helmet/space/pirate = 10,
					/obj/item/clothing/suit/space/freedom = 10,
					/obj/item/clothing/head/helmet/space/freedom = 10,
					/obj/item/clothing/suit/space/hardsuit/carp = 10,
					/obj/item/clothing/suit/space/hardsuit/combatmedic = 10,
					/obj/item/clothing/suit/space/syndicate = 10,
					/obj/item/clothing/head/helmet/space/syndicate = 10,
					/obj/item/clothing/suit/space/syndicate/contract = 10,
					/obj/item/clothing/head/helmet/space/syndicate/contract = 10,
					/obj/item/clothing/suit/armor/bone = 10,
					/obj/item/clothing/suit/armor/vest/infiltrator = 10,
					/obj/item/clothing/suit/armor/vest/russian = 10,
					/obj/item/clothing/suit/armor/vest/russian_coat = 10,
					/obj/item/clothing/suit/hooded/cloak/goliath = 10,
					/obj/item/clothing/suit/hooded/cloak/drake = 10,
					/obj/item/clothing/suit/yakuza = 10,
					/obj/item/clothing/suit/dutch = 10,
					/obj/item/clothing/head/wizard = 10,
					/obj/item/clothing/suit/wizrobe = 10,
					/obj/item/clothing/head/wizard/red = 10,
					/obj/item/clothing/suit/wizrobe/red = 10,
					/obj/item/clothing/head/wizard/yellow = 10,
					/obj/item/clothing/suit/wizrobe/yellow = 10,
					/obj/item/clothing/head/wizard/black = 10,
					/obj/item/clothing/suit/wizrobe/black = 10,
					/obj/item/clothing/head/wizard/marisa = 10,
					/obj/item/clothing/suit/wizrobe/marisa = 10,
					/obj/item/clothing/head/wizard/magus = 10,
					/obj/item/clothing/suit/wizrobe/magusred = 10,
					/obj/item/clothing/suit/wizrobe/magusblue = 10,
					/obj/item/clothing/head/wizard/santa = 10,
					/obj/item/clothing/suit/wizrobe/santa = 10,
					/obj/item/clothing/gloves/bracer = 10,
					/obj/item/clothing/gloves/combat/wizard = 10,
					/obj/item/toy/sprayoncan = 10,
					/obj/item/clothing/gloves/color/yellow = 10,
					/obj/item/clothing/gloves/color/captain = 10,
					/obj/item/clothing/gloves/color/latex/nitrile/infiltrator = 10,
					/obj/item/clothing/gloves/color/latex/engineering = 10,
					/obj/item/clothing/under/costume/mummy = 10,
					/obj/item/clothing/under/costume/draculass = 10,
					/obj/item/clothing/under/costume/drfreeze = 10,
					/obj/item/clothing/under/costume/skeleton = 10,
					/obj/item/clothing/under/costume/russian_officer = 10,
					/obj/item/clothing/under/costume/jackbros = 10,
					/obj/item/clothing/under/costume/yakuza = 10,
					/obj/item/clothing/under/costume/dutch = 10,
					/obj/item/clothing/under/syndicate = 10,
					/obj/item/clothing/under/syndicate/skirt = 10,
					/obj/item/clothing/under/syndicate/bloodred = 10,
					/obj/item/clothing/under/syndicate/tacticool = 10,
					/obj/item/clothing/under/syndicate/tacticool/skirt = 10,
					/obj/item/clothing/under/syndicate/sniper = 10,
					/obj/item/clothing/under/syndicate/camo = 10,
					/obj/item/clothing/under/syndicate/soviet = 10,
					/obj/item/clothing/under/syndicate/combat = 10,
					/obj/item/clothing/under/syndicate/rus_army = 10,
					/obj/item/cardpack/series_one = 50,
					/obj/item/cardpack/resin = 50)
	contraband = list()
	premium = list()
