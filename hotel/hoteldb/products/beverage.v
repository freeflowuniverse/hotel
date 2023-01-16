module hoteldb

import freeflowuniverse.crystalib.params

[heap] 
pub struct Beverage{
	ProductMixin
	ConsumableMixin
pub mut:
	alcoholic   bool
}

pub fn (hdb HotelDB) add_beverage (o params.Params) {

	beverage := Beverage{
		id : o.get('id')
		name : o.get('name')
		url : o.get('url')
		description : o.get('description')
		price : amount_get(o.get('price'))
		state: match_state(o.get('state'))
		calories : o.get('calories').int()
		vegetarian : o.get('vegetarian').bool()
		vegan : o.get('vegan').bool()
		allergens: hdb.get_allergens(os.get('allergens'))
		alcoholic: o.get('alcoholic').bool()
	}

	hdb.products << beverage

}