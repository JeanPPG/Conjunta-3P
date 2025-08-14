const createRetoRealPanel = () => {
    Ext.define('App.model.RetoReal', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'titulo', type: 'string' },
            { name: 'descripcion', type: 'string' },
            { name: 'complejidad', type: 'string' },            // 'facil' | 'media' | 'dificil'
            { name: 'areas_conocimiento', type: 'auto' },       // Array / JSON
            { name: 'entidad_colaboradora', type: 'string' }
        ]
    });

    const retoRealStore = Ext.create('Ext.data.Store', {
        storeId: 'retoRealStore',
        model: 'App.model.RetoReal',
        proxy: {
            type: 'rest',
            url: '/api/retos_reales.php', // endpoint del controlador de Reto Real
            reader: {
                type: 'json',
                rootProperty: ''
            },
            writer: {
                type: 'json',
                writeAllFields: true
            },
            appendId: false
        },
        autoLoad: true,
        autoSync: false
    });

    const renderAreas = (value) => {
        if (!value) return '';
        let arr = value;
        if (Ext.isString(value)) {
            try { arr = JSON.parse(value); } catch (e) { return value; }
        }
        return Ext.isArray(arr) ? arr.join(', ') : value;
    };

    return Ext.create('Ext.grid.Panel', {
        title: 'Retos Reales',
        store: retoRealStore,
        columns: [
            { text: 'ID', dataIndex: 'id', width: 80 },
            { text: 'Título', dataIndex: 'titulo', flex: 2 },
            { text: 'Descripción', dataIndex: 'descripcion', flex: 3 },
            { text: 'Complejidad', dataIndex: 'complejidad', width: 120 },
            { text: 'Áreas de Conocimiento', dataIndex: 'areas_conocimiento', flex: 2, renderer: renderAreas },
            { text: 'Entidad Colaboradora', dataIndex: 'entidad_colaboradora', width: 220 }
        ]
    });
};
