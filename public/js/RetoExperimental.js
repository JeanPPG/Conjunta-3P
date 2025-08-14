const createRetoExperimentalPanel = () => {
    Ext.define('App.model.RetoExperimental', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'titulo', type: 'string' },
            { name: 'descripcion', type: 'string' },
            { name: 'complejidad', type: 'string' }, // 'facil' | 'media' | 'dificil'
            { name: 'areas_conocimiento', type: 'auto' }, // Array/JSON
            { name: 'enfoque_pedagogico', type: 'string' }
        ]
    });

    const retoExperimentalStore = Ext.create('Ext.data.Store', {
        storeId: 'retoExperimentalStore',
        model: 'App.model.RetoExperimental',
        proxy: {
            type: 'rest',
            url: '/api/retos_experimentales.php', // endpoint del controlador
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
        // value puede ser array o string JSON
        if (!value) return '';
        let arr = value;
        if (Ext.isString(value)) {
            try { arr = JSON.parse(value); } catch (e) { return value; }
        }
        return Ext.isArray(arr) ? arr.join(', ') : value;
    };

    return Ext.create('Ext.grid.Panel', {
        title: 'Retos Experimentales',
        store: retoExperimentalStore,
        columns: [
            { text: 'ID', dataIndex: 'id', width: 80 },
            { text: 'Título', dataIndex: 'titulo', flex: 2 },
            { text: 'Descripción', dataIndex: 'descripcion', flex: 3 },
            { text: 'Complejidad', dataIndex: 'complejidad', width: 120 },
            { text: 'Áreas de Conocimiento', dataIndex: 'areas_conocimiento', flex: 2, renderer: renderAreas },
            { text: 'Enfoque Pedagógico', dataIndex: 'enfoque_pedagogico', width: 180 }
        ]
    });
};
