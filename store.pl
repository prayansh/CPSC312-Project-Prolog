% This is the knowledge base for the store domain

% store constants
door(pos(0,0)).
exit(pos(5,5)).
sizeX(5).
sizeY(5).

prop(apple, name, "Apple").
prop(apple, weight, 10).
prop(apple, price, 2).

prop(banana, name, "Banana").
prop(banana, weight, 10).
prop(banana, price, 3).

prop(carrot, name, "Carrot").
prop(carrot, weight, 20).
prop(carrot, price, 5).

prop(date, name, "Date").
prop(date, weight, 30).
prop(date, price, 2).

% shelf(id, product)
shelf(s1, apple).
shelf(s2, banana).
shelf(s3, carrot).
shelf(s4, date).
shelf(s5, apple).
shelf(s6, carrot).

% predicates
item(N, W, P) :- prop(X, name, N), prop(X, weight, W), prop(X, price, P).

% shelf_item_count(time, id, item name, number) : gets the number N of items with name IN in shelf with id ID at time T 
shelf_item_count(T, ID, IN, N):- shelf(ID, I),  measurement(ID, W, T, _), prop(I, weight, IW),  N is (W / IW), prop(I, name, IN).

% store_item_count(time, item name, number) : gets the number N of items with name IN remaining in the shelfs at time T
store_item_count(T, IN, N):- findall(SN, shelf_item_count(T, _, IN, SN), L), sumlist(L, N). 

% calc_price(item, number, price): calculates the price P of N items of item I
calc_price(I, N, P):- prop(I, price, IP), P is (IP*N).

% basket_price(time, basket id, price): get the price P of all items in basket with id ID at time T
basket_price(T, ID, P):- findall(IP, (basket_has(T, ID, I, N), calc_price(I, N, IP)), L), sumlist(L, P).

%% basket_has(T, ID, P, N):- TODO.

basket_has(0, b1, apple, 2).
basket_has(0, b1, date, 1).

% can_buy(time, basket id, shelve id): a person with basket BID can buy from the shelf SID at time T
can_buy(T, BID, SID):- measurement(BID, _, T, BP), measurement(SID, _, T, SP), m_distance(BP,SP,MD), MD is 1.

m_distance(pos(X1,Y1),pos(X2,Y2),MD):- X is (X1-X2), abs(X,XD), Y is (Y1-Y2), abs(Y,YD), MD is (XD + YD).


% Story
% mat a has weight 0 at time 0 at pos(0,0)
% measurement_raw(id, weight, time, position)
measurement_raw(s1, 40, 0, pos(2,1)). % 4 apples
measurement_raw(s2, 70, 0, pos(3,1)). % 7 bananas
measurement_raw(s3, 100, 0, pos(2,2)). % 5 carrots
measurement_raw(s4, 150, 0, pos(3,2)). % 5 dates
measurement_raw(s5, 30, 0, pos(2,3)). % 3 apples
measurement_raw(s6, 60, 0, pos(3,3)). % 3 carrots

% User u has entered
measurement_raw(b1, 0, 0, pos(0,0)). % user’s mat_id=u
measurement_raw(b1, 0, 1, pos(1,0)).
measurement_raw(b1, 0, 2, pos(1,1)).
measurement_raw(b1, 10, 3, pos(1,1)). % get 1 apple from a
measurement_raw(s1, 30, 3, pos(2,1)).

measurement_raw(b1, 10, 4, pos(1,2)).
measurement_raw(b1, 10, 5, pos(1,3)).
measurement_raw(b1, 30, 6, pos(1,3)). % get 2 apple from e
measurement_raw(s5, 10, 6, pos(2,3)).

measurement_raw(b1, 30, 7, pos(1,4)).
measurement_raw(b1, 30, 8, pos(2,4)).
measurement_raw(b1, 30, 9, pos(3,4)).
measurement_raw(b1, 40, 10, pos(3,4)).
measurement_raw(s6, 50, 10, pos(3,3)).

measurement_raw(b1, 40, 11, pos(3,5)).
measurement_raw(b1, 40, 12, pos(4,5)).
measurement_raw(b1, 40, 13, pos(5,5)).

measurement_raw(_, _, -1, pos(-1,-1)).



% Use measurement for actually retrieving values
measurement(X, W, T, P):- measurement_raw(X, W, T, P).
measurement(X, W, T, P):- T0 is T - 1, T >= -1,  measurement(X, W, T0, P), not(measurement_raw(X, _, T, _)).

pos_in_store(X, Y):- sizeX(XS), MAX_X is XS, sizeY(YS), MAX_Y is YS, between(0,MAX_X,X), between(0,MAX_Y,Y).
pos_in_store(pos(X, Y)):- pos_in_store(X,Y).

is_in_store(M):- measurement(M, _, _, P), pos_in_store(P).
