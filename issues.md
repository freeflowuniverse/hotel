# Issues

## 1. Library

### 1.1 Product Amount

Should constituent products be a quantity and a product id, or a full product amount. The issue with making it a full product amount is that if the product amount is updated in its original state, then outdated information is being persisted. However, it is also useful to be able to easily access that information. My solution is to introduce a method of the product class which gathers the constituent_products through use of the actor_name and and the product_id. I think product_name needs to be there as well for ease of access but this still presents the same issue. Ideally I could use references, but that might be problematic as well. Maybe a third solution is to make the function get_constituents_from. However, I now struggle because the stringify function can't access the []Product if it is defined here, so then name needs to be reintroducted but we are now faced with the same issue.

## 2. Actors

2.1 SOLVED Actor Model Import Cycle

I faced the issue of having multiple import cycles in part because I would need actor models to be used in various clients (for example when requesting a user instance), but then this would almost always clash with the necessary client imports. Therefore, I moved the actor models to the library where it is import only. This problem seems to be solved but now I am unsure what the standard model structure should be.

2.2 SOLVED Actor Flavors

It is necessary to have flavors of different actors, ie employee and guest flavors of the user model. Is the best way to do this with interfaces, embedded structs, attribute structs or by duplicating information?

### 2.3 Threading

Which processes should be on threads and which should be synchronous?

## 3. General

### 3.1 Passing data around

How should data be passed around, by individual fields placed into params or by encoding the whole struct? Doing the whole struct seems more lightweight and requires less duplication, because every time the struct definition is changed, imports still work.

## 4. Client Builder

### 4.1 Interpreting Sum Types and Interfaces

the client builder works by recognising data types but this can provide complications when an actor method returns either an employee or a guest. There are several possible solutions for this; create separate functions for every sum type constituent, or work out some intelligent way to cast and decipher the type in the client. 

### 4.2 Template files

I initially tried to use templates to create the client, but this didnt work because I was unable to do for loops to write the inputs and outputs of the different client functions. I thought that it would be possible to use fmt as a shortcut to fix the problematic code, but I was unable to get this to work. My solution has been to do a pseduo template where I jsut add lines to a string with string interpolation for the custom values and then write to a v file.

### 4.3 Test files

Should I create test files with the client builder or rather just boiler plate for testing, if so then that needs to be a separate process, because otherwise all customizations will be deleted on every build. (ie a one time code generation as opposed to a dynamic/live code generation).`

## 5. Flows

### 5.1 Flow Code Structure

I have tried several different iterations of flow structures from having continous logic with for loops to perform repeatability, to making every individual action its own function and having functions call each subsequent one (like nodes in a tree). While the latter makes a lot of logical sense, it doubles/triples the amount of necessary code just for function declaration and matching inputs/outputs etc. A good middle ground seemed to be grouping together interatcions with the user by logically repeatable units. Moreover, I used a flow struct to maintain state throughout, so I wouldn't need to worry about passing data to and from functions, instead they are all just methods.

### 5.2 User Experience

What should the initial introduction to a user to the hms be? Presented with a list of facilities? ie restaurant, bar, spa and then from there they can pick individual instances ie the bar by the pontoon or a secondary bar (not that we have one yet).

### 5.3 Add, Edit, Delete

What should the process be for adding, editing, deleting a new instance ie users, new products, new actors. In a Wizard format it is very unintuitive to edit a structure because either you have to go through items one by one deciding whether or not you want to modify them or you can have a dropdown selection which allows you to modify individual fields by selecting them (this then becomes problematic if you want to modify 4/5 fields). Also what about deleting products for example, theoretically you want to always keep a record of old products, ie to see orders of that type in the past, so maybe just make them 'cancelled', but what if someone adds a product by mistake? we dont want the system to be flooded with lots of totally unnecessary data either. Seems like having two types of delete would be best ie you can either 'end product' or 'delete product'.

## 6. Dependencies

### 6.1 Baobab

How do I make sure that this hotel management system is compatible with baobab even when it is undergoing an upgrade. 

### 6.2 UI Client

How do I make sure my code is compatible with the ui client when it is not finished yet, should I change my priorities to get that done first? Things that need to be done (initialization of clients, dropdown questions, regular questions, more niche questions such as date, time, email, address). 

