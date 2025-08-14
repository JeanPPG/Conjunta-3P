const createEstudiantePanel = () => {
    Ext.define('App.model.Estudiante',{
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'nombre', type: 'string' },
            { name: 'email', type: 'string' },
            { name: 'nivel_habilidad', type: 'string' },
            { name: 'habilidades', type: 'auto' },
            { name: 'grado', type: 'int'},
            { name: 'institucion', type: 'string'},
            { name: 'tiempo_disponible_semanal', type: 'int'}
        ]
    });

    const estudianteStore = Ext.create('Ext.data.Store', {
        storeId: 'estudianteStore',
        model: 'App.model.Estudiante',
        proxy: {
            type: 'rest',
            url: '/api/estudiantes.php',
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

    return Ext.create('Ext.grid.Panel', {
        title: 'Estudiantes',
        store: estudianteStore,
        columns: [
            { text: 'ID', dataIndex: 'id', flex: 1 },
            { text: 'Nombre', dataIndex: 'nombre', flex: 2 },
            { text: 'Email', dataIndex: 'email', flex: 2 },
            { text: 'Nivel de Habilidad', dataIndex: 'nivel_habilidad', flex: 1 },
            { text: 'Habilidades', dataIndex: 'habilidades', flex: 2 },
            { text: 'Grado', dataIndex: 'grado', flex: 1 },
            { text: 'Institución', dataIndex: 'institucion', flex: 2 },
            { text: 'Tiempo Disponible Semanal', dataIndex: 'tiempo_disponible_semanal', flex: 1 }
        ]
    });
}