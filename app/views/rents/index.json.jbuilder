json.rents do
  json.array! @rents, partial: 'rent', as: :rent
end

json.total @total
