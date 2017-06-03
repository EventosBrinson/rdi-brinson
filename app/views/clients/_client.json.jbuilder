json.id client.id
json.firstname client.firstname
json.lastname client.lastname
json.address_line_1 client.address_line_1
json.address_line_2 client.address_line_2
json.telephone_1 client.telephone_1
json.telephone_2 client.telephone_2
json.id_name client.id_name
json.trust_level client.trust_level
json.active client.active
json.creator_id client.creator_id
json.created_at client.created_at
json.documents do
  json.array! client.documents, partial: 'documents/document', as: :document
end
