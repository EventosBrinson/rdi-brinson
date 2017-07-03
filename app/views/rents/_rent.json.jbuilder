json.id rent.id
json.order_number rent.order_number
json.delivery_time rent.delivery_time
json.pick_up_time rent.pick_up_time
json.product rent.product
json.price rent.price
json.discount rent.discount
json.additional_charges rent.additional_charges
json.additional_charges_notes rent.additional_charges_notes
json.rent_type rent.rent_type
json.status rent.status
json.created_at rent.created_at
json.creator_id rent.creator_id
json.client do
  json.id rent.client.id
  json.firstname rent.client.firstname
  json.lastname rent.client.lastname
end
json.place do
  json.partial! 'places/place', place: rent.place
end


