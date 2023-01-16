# Rooms List

## Parameters
- id
- name
- url
- description
- price
- state : [ok, planned, unavailable, endoflife, error] (default=ok)
- room_number
- double_count
- single_count
- view : [sea, garden] (default=sea)
- ensuite              (default=true)

!! room.add
id: 'R01'
name: 'First Suite'
url: 'not sure?'
description: 'The primary suite of the JP Hotel'
price: '150usd'
state: 'ok'
room_number: '1'
double_count: '1'
single_count: '0'