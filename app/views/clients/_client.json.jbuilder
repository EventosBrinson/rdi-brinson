json.id client.id
json.firstname client.firstname
json.lastname client.lastname
json.street client.street
json.inner_number client.inner_number
json.outer_number client.outer_number
json.neighborhood client.neighborhood
json.postal_code client.postal_code
json.telephone_1 client.telephone_1
json.telephone_2 client.telephone_2
json.email client.email
json.id_name client.id_name
json.trust_level client.trust_level
json.active client.active
json.creator_id client.creator_id
json.created_at client.created_at
json.documents do
  json.array! client.documents, partial: 'documents/document', as: :document
end
json.places do
  json.array! client.places, partial: 'places/place', as: :place
end
