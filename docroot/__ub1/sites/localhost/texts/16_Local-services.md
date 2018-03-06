Data sets can optionally implement **local services**, rather than consume remote web services via HTTP requests.

A _local service_ can be executed in the server, in the client, or in both. When the client needs data from a server-side local service, an HTTP request is transparently made behind the scenes.

The `<ub1-dataset>` tag in the code above is similar to the one used in this playground itself to get the list of available samples. Being a server-side service, it's allowed to use the FileSystem object to list directories.

The same approach can be used to implement a server-side service that works with a centralized DB, or client-side service that handles a local DB in the client.