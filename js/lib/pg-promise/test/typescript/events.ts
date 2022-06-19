import * as pgPromise from '../../typescript/pg-promise';

const pgp: pgPromise.IMain<{}, MyClient> = pgPromise({
    connect(client) {
        const v = client.version;
    },
    receive(data: any, result: any, e: any) {
        const dc = e.dc;
        const d = data[0].prop;
        const r = result.fields[0].name;
        const query = e.query;
    },
    query(e: any) {
        const dc = e.dc;
        const query = e.query;
    },
    error(err: any, e: any) {
        const dc = e.dc;
        const query = e.query;
    },
    extend(obj: any, dc: any) {
        obj['method'] = (val: any) => {
            return obj.one(null, val);
        }
    }
});

class MyClient extends pgp.pg.Client {
    version?: string;
}

const db = pgp({
    Client: MyClient
});

db.task(t => {
    const dc = t.ctx.dc;
    const useCount = t.ctx.useCount;
    return t.batch([
        t.one('query'),
        t.none('query')
    ]);
})
    .then(data => {
    })
    .catch(error => {

    });
