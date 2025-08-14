const createMentorTecnicoPanel = () => {
    Ext.define('App.model.MentorTecnico',{
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'nombre', type: 'string' },
            { name: 'email', type: 'string' },
            { name: 'nivel_habilidad', type: 'string' },
            { name: 'habilidades', type: 'auto' },
            { name: 'especialidad', type: 'string' },
            { name: 'experiencia', type: 'int' },
            { name: 'disponibilidad_horaria', type: 'string' }
        ]
    });

    const mentorTecnicoStore = Ext.create('Ext.data.Store', {
        storeId: 'mentorTecnicoStore',
        model: 'App.model.MentorTecnico',
        proxy: {
            type: 'rest',
            url: '/api/mentortecnico.php',
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
        title: 'Mentores Técnicos',
        store: mentorTecnicoStore,
        columns: [
            { text: 'ID', dataIndex: 'id', flex: 1 },
            { text: 'Nombre', dataIndex: 'nombre', flex: 2 },
            { text: 'Email', dataIndex: 'email', flex: 2 },
            { text: 'Nivel de Habilidad', dataIndex: 'nivel_habilidad', flex: 1 },
            { text: 'Habilidades', dataIndex: 'habilidades', flex: 2 },
            { text: 'Especialidad', dataIndex: 'especialidad', flex: 1 },
            { text: 'Años de Experiencia', dataIndex: 'experiencia', flex: 1 },
            { text: 'Disponibilidad Horaria', dataIndex: 'disponibilidad_horaria', flex: 2 }
        ]
    });
}