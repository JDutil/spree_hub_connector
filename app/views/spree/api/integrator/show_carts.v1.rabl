object false

child(@carts => :carts) do
  extends('spree/api/integrator/show_order')
end

node(:count) { @carts.count }
node(:current_page) { @page }
node(:pages) { @carts.num_pages }

