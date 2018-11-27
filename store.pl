% This is the knowledge base for the store domain

% store constants
door(pos(0,0)).
exit(pos(5,5)).

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

shelf(a, apple).
shelf(b, banana).
shelf(c, carrot).
shelf(d, date).
shelf(e, apple).
shelf(f, carrot).

% predicates
item(N, W, P) :- prop(X, name, N), prop(X, weight, W), prop(X, price, P).


% Story
% mat a has weight 0 at time 0 at pos(0,0)
measurement(a, 40, 0, pos(2,1)). % 4 apples
measurement(b, 70, 0, pos(3,1)). % 7 bananas
measurement(c, 100, 0, pos(2,2)). % 5 carrots
measurement(d, 150, 0, pos(3,2)). % 5 dates
measurement(e, 30, 0, pos(2,3)). % 3 apples
measurement(f, 60, 0, pos(3,3)). % 3 carrots

% User u has entered
measurement(u, 0, 0, pos(0,0)). % user’s mat_id=u
measurement(u, 0, 1, pos(1,0)).
measurement(u, 0, 2, pos(1,1)).
measurement(u, 10, 3, pos(1,1)). % get 1 apple from a
measurement(a, 30, 3, pos(2,1)).

measurement(u, 10, 4, pos(1,2)).
measurement(u, 10, 5, pos(1,3)).
measurement(u, 30, 6, pos(1,3)). % get 2 apple from e
measurement(e, 10, 6, pos(2,3)).

measurement(u, 30, 7, pos(1,4)).
measurement(u, 30, 8, pos(2,4)).
measurement(u, 30, 9, pos(3,4)).
measurement(u, 40, 10, pos(3,4)).
measurement(f, 50, 10, pos(3,3)).

measurement(u, 40, 11, pos(3,5)).
measurement(u, 40, 12, pos(4,5)).
measurement(u, 40, 13, pos(5,5)).
