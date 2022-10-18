" Create command using g:vimkubectl_command
fun! s:craftCmd(command, namespace = '') abort
  let nsFlag = len(a:namespace) ? '-n ' . a:namespace : ''
  let timeoutFlag = '--request-timeout=' . get(g:, 'vimkubectl_timeout', 5) . 's'
  return join([get(g:, 'vimkubectl_command', 'kubectl'), a:command, l:nsFlag, l:timeoutFlag])
endfun

fun! s:asyncCmd(command) abort
  return ['bash', '-c', a:command]
endfun

" Fetch list of all namespaces
" returns string of space-separated values
fun! vimkubectl#kube#fetchNamespaces() abort
  return system(s:craftCmd('get ns -o custom-columns=":metadata.name"'))
endfun

" Fetch list of resource types
" Note: This uses --cached
" returns string of space-separated values
fun! vimkubectl#kube#fetchResourceTypes() abort
  return system(s:craftCmd(join(['api-resources', '--cached', '-o name'])))
endfun

" Fetch list of resources of a given type
" returns array of `resourceType/resourceName`
fun! vimkubectl#kube#fetchResourceList(resourceType, namespace) abort
  return systemlist(s:craftCmd(join(['get', a:resourceType, '-o name']), a:namespace))
endfun

" Same as above but returns only list of `resourceName`
" returns string of space-separated values
fun! vimkubectl#kube#fetchPureResourceList(resourceType, namespace) abort
  return system(s:craftCmd(join(['get', a:resourceType, '-o custom-columns=":metadata.name"']), a:namespace))
endfun

" Fetch manifest of resource
" returns array of strings of each line
fun! vimkubectl#kube#fetchResourceManifest(resourceType, resource, namespace) abort
  return systemlist(s:craftCmd(join(['get', a:resourceType, a:resource, '-o yaml']), a:namespace))
endfun

" Apply string
fun! vimkubectl#kube#applyString(stringData, namespace) abort
  return system(s:craftCmd('apply -f -', a:namespace), a:stringData)
endfun

" Get currently active namespace
fun! vimkubectl#kube#fetchActiveNamespace() abort
  return system(s:craftCmd('config view --minify -o ''jsonpath={..namespace}'''))
endfun

" Delete resource
fun! vimkubectl#kube#deleteResource(resType, res, ns, onDel) abort
  let cmd = s:craftCmd(join(['delete', a:resType, a:res]), a:ns)
  return vimkubectl#util#asyncRun(s:asyncCmd(l:cmd), a:onDel)
endfun

" Set active namespace for current context
fun! vimkubectl#kube#setNs(ns, onSet) abort
  const cmd = s:craftCmd('config set-context --current --namespace=' . a:ns)
  return vimkubectl#util#asyncRun(s:asyncCmd(l:cmd), a:onSet)
endfun

" Fetch list of resources of a given type
" returns array of `resourceType/resourceName`
fun! vimkubectl#kube#fetchResourceList2(resourceType, namespace, callback, ctx = {}) abort
  const cmd = s:craftCmd(join(['get', a:resourceType, '-o name']), a:namespace)
  return vimkubectl#util#asyncRun(s:asyncCmd(l:cmd), a:callback, 'array', a:ctx)
endfun

" vim: et:sw=2:sts=2:
