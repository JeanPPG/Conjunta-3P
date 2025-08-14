Ext.onReady(() => {
    const estudiantePanel = createEstudiantePanel();
    const mentorTecnicoPanel = createMentorTecnicoPanel();
   

    const mainCard = Ext.create('Ext.panel.Panel', {
        region: 'center',
        layout: 'card',
        items: [
            estudiantePanel,
            mentorTecnicoPanel
        ],
    });

    Ext.create('Ext.container.Viewport', {
        id: 'mainViewport',
        layout: 'border',
        items: [
            {
                region: 'north',
                xtype: 'toolbar',
                items: [
                    {
                        text: 'Estudiantes',
                        handler: () => {
                            mainCard.getLayout().setActiveItem(estudiantePanel);
                        }
                    },
                    {
                        text: 'Mentores Técnicos',
                        handler: () => {
                            mainCard.getLayout().setActiveItem(mentorTecnicoPanel);
                        }
                    },
                ],
            },
            mainCard,
        ],
    });
});
