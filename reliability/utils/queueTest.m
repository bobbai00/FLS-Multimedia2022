function a = queueTest()
q = queue();

q = q.pushBack(1);
q = q.pushBack(2);
q.front()
q = q.pop();
q.front()
q = q.pop();
q.isEmpty()
q = q.pushBack(9);
q.isEmpty()
q.front()
q = q.pop();
q.isEmpty()
end

