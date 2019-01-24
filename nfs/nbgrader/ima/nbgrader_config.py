c = get_config()
c.Exchange.root = "/tmp/exchange"
c.CourseDirectory.root = "/home/jovyan/work/InfoII"
c.BaseConverter.groupshared = True
c.Exchange.course_id = "InfoII"
#c.ClearSolutions.begin_solution_delimeter = {'haskell' : '// BEGIN SOLUTION'}
#c.ClearSolutions.end_solution_delimeter = {'haskell' : '// END SOLUTION'}
c.ClearSolutions.code_stub = {'haskell' : '// your code here...', 'python': '### BEGIN SOLUTION'}
